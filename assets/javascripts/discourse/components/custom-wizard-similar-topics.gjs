/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import { i18n } from "discourse-i18n";
import CustomWizardSimilarTopic from "./custom-wizard-similar-topic";

@classNames("wizard-similar-topics")
export default class CustomWizardSimilarTopics extends Component {
  showTopics = true;

  didInsertElement() {
    super.didInsertElement(...arguments);
    this._documentClickHandler = this.documentClick.bind(this);
    document.addEventListener("click", this._documentClickHandler);
  }

  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);

    if (this._topics !== this.topics) {
      this._topics = this.topics;
      this.set("showTopics", true);
    }
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    document.removeEventListener("click", this._documentClickHandler);
  }

  documentClick(e) {
    if (this._state === "destroying") {
      return;
    }
    if (!e.target.classList.contains("show-topics")) {
      this.set("showTopics", false);
    }
  }

  @action
  toggleShowTopics() {
    this.set("showTopics", true);
  }

  <template>
    {{#if this.showTopics}}
      <ul>
        {{#each this.topics as |topic|}}
          <li><CustomWizardSimilarTopic @topic={{topic}} /></li>
        {{/each}}
      </ul>
    {{else}}
      <a role="button" class="show-topics" {{on "click" this.toggleShowTopics}}>
        {{i18n "realtime_validations.similar_topics.show"}}
      </a>
    {{/if}}
  </template>
}
