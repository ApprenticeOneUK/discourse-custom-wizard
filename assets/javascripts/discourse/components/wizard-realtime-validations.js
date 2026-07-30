/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import EmberObject, { action, computed } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import { cloneJSON } from "discourse/lib/object";
import Category from "discourse/models/category";
import { i18n } from "discourse-i18n";

@classNames("realtime-validations", "setting", "full", "subscription")
export default class WizardRealtimeValidations extends Component {
  init() {
    super.init(...arguments);
    if (!this.validations) {
      return;
    }

    if (!this.field.validations) {
      const validations = {};

      this.validations.forEach((validation) => {
        validations[validation] = {};
      });

      this.set("field.validations", EmberObject.create(validations));
    }

    const validationBuffer = cloneJSON(this.get("field.validations"));
    if (validationBuffer.similar_topics) {
      const bufferCategories = validationBuffer.similar_topics.categories || [];
      validationBuffer.similar_topics.categories =
        Category.findByIds(bufferCategories);
    }
    this.set("validationBuffer", validationBuffer);
  }

  get timeUnits() {
    return ["days", "weeks", "months", "years"].map((unit) => {
      return {
        id: unit,
        name: i18n(`admin.wizard.field.validations.time_units.${unit}`),
      };
    });
  }

  @computed("field.validations")
  get validationRows() {
    if (!this.field.validations) {
      return [];
    }

    return Object.keys(this.field.validations).map((type) => ({
      type,
      props: this.field.validations[type],
      isSimilarTopics: type === "similar_topics",
      isAnswer: type === "answer",
    }));
  }

  @action
  updateValidationCategories(type, validation, categories) {
    this.set(`validationBuffer.${type}.categories`, categories);
    this.set(
      `field.validations.${type}.categories`,
      categories.map((category) => category.id)
    );
  }
}
