/* eslint-disable ember/no-actions-hash, ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { observes } from "discourse/lib/decorators";

export default Component.extend({
  classNames: ["wizard-similar-topics"],
  showTopics: true,

  didInsertElement() {
    this._super(...arguments);
    this._documentClickHandler = this.documentClick.bind(this);
    document.addEventListener("click", this._documentClickHandler);
  },

  willDestroyElement() {
    this._super(...arguments);
    document.removeEventListener("click", this._documentClickHandler);
  },

  documentClick(e) {
    if (this._state === "destroying") {
      return;
    }
    if (!e.target.classList.contains("show-topics")) {
      this.set("showTopics", false);
    }
  },

  @observes("topics")
  toggleShowWhenTopicsChange() {
    this.set("showTopics", true);
  },

  actions: {
    toggleShowTopics() {
      this.set("showTopics", true);
    },
  },
});
