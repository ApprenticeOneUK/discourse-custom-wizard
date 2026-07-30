import EmberObject, { action, computed } from "@ember/object";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { cancel, later } from "@ember/runloop";
import { dasherize } from "@ember/string";
import { trustHTML } from "@ember/template";
import { classNames } from "@ember-decorators/component";
import { deepMerge } from "discourse/lib/object";
import { categoryBadgeHTML } from "discourse/ui-kit/helpers/d-category-link";
import { i18n } from "discourse-i18n";
import WizardFieldValidator from "discourse/plugins/discourse-custom-wizard/discourse/components/validator";
import CustomWizardSimilarTopics from "./custom-wizard-similar-topics";

@classNames("similar-topics-validator")
export default class SimilarTopicsValidator extends WizardFieldValidator {
  similarTopics = null;

  @computed("field.value")
  get hasInput() {
    return Boolean(this.field.value);
  }

  @computed("similarTopics.[]")
  get hasSimilarTopics() {
    return Boolean(this.similarTopics?.length);
  }

  @computed("similarTopics")
  get hasNotSearched() {
    return this.similarTopics === null;
  }

  @computed("similarTopics.[]")
  get noSimilarTopics() {
    return this.similarTopics !== null && this.similarTopics.length === 0;
  }

  @computed("typing", "hasSimilarTopics")
  get showSimilarTopics() {
    return this.hasSimilarTopics && !this.typing;
  }

  @computed("typing", "noSimilarTopics")
  get showNoSimilarTopics() {
    return this.noSimilarTopics && !this.typing;
  }

  @computed("validationCategories.[]")
  get hasValidationCategories() {
    return Boolean(this.validationCategories.length);
  }

  @computed("typing", "field.value")
  get insufficientCharacters() {
    return this.hasInput && this.field.value.length < 5 && !this.typing;
  }

  @computed("insufficientCharacters", "hasValidationCategories")
  get insufficientCharactersCategories() {
    return this.insufficientCharacters && this.hasValidationCategories;
  }

  @computed("validation.categories")
  get validationCategories() {
    if (this.validation.categories) {
      return this.validation.categories.map(
        (id) => this.site.categoriesById[id]
      );
    }

    return [];
  }

  @computed("validationCategories.[]")
  get catLinks() {
    return this.validationCategories
      .map((category) => categoryBadgeHTML(category))
      .join("");
  }

  @computed(
    "loading",
    "showSimilarTopics",
    "showNoSimilarTopics",
    "insufficientCharacters",
    "insufficientCharactersCategories"
  )
  get currentState() {
    switch (true) {
      case this.loading:
        return "loading";
      case this.showSimilarTopics:
        return "results";
      case this.showNoSimilarTopics:
        return "no_results";
      case this.insufficientCharactersCategories:
        return "insufficient_characters_categories";
      case this.insufficientCharacters:
        return "insufficient_characters";
      default:
        return false;
    }
  }

  @computed("currentState")
  get currentStateClass() {
    if (this.currentState) {
      return `similar-topics-${dasherize(this.currentState)}`;
    }

    return "similar-topics";
  }

  @computed("currentState")
  get currentStateKey() {
    if (this.currentState) {
      return `realtime_validations.similar_topics.${this.currentState}`;
    }

    return false;
  }

  validate() {}

  @action
  customValidate() {
    const field = this.field;

    if (!field.value) {
      this.set("similarTopics", null);
      return;
    }
    const value = field.value;

    this.set("typing", true);

    const lastKeyUp = new Date();
    this._lastKeyUp = lastKeyUp;

    // One second from now, check to see if the last key was hit when
    // we recorded it. If it was, the user paused typing.
    cancel(this._lastKeyTimeout);
    this._lastKeyTimeout = later(() => {
      if (lastKeyUp !== this._lastKeyUp) {
        return;
      }
      this.set("typing", false);

      if (value && value.length < 5) {
        this.set("similarTopics", null);
        return;
      }

      this.updateSimilarTopics();
    }, 1000);
  }

  updateSimilarTopics() {
    this.set("similarTopics", null);
    this.set("updating", true);

    this.backendValidate({
      title: this.get("field.value"),
      categories: this.get("validation.categories"),
      time_unit: this.get("validation.time_unit"),
      time_n_value: this.get("validation.time_n_value"),
    })
      .then((result) => {
        const similarTopics = deepMerge(
          result.topics,
          result.similar_topics
        ).map((topic) => EmberObject.create(topic));

        this.set("similarTopics", similarTopics);
      })
      .finally(() => this.set("updating", false));
  }

  @action
  closeMessage() {
    this.set("showMessage", false);
  }

  <template>
    <label
      class={{this.currentStateClass}}
      {{didUpdate this.customValidate this.field.value}}
    >
      {{#if this.currentState}}
        {{#if this.insufficientCharactersCategories}}
          {{trustHTML (i18n this.currentStateKey catLinks=this.catLinks)}}
        {{else}}
          {{i18n this.currentStateKey}}
        {{/if}}
      {{/if}}
    </label>

    {{#if this.showSimilarTopics}}
      <CustomWizardSimilarTopics @topics={{this.similarTopics}} />
    {{/if}}
  </template>
}
