/* eslint-disable ember/avoid-leaking-state-in-ember-objects, ember/no-actions-hash, ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";

export default Component.extend({
  topics: [],

  didInsertElement() {
    this._super(...arguments);
    const value = this.field.value;

    if (value) {
      this.set("topics", value);
    }
  },

  actions: {
    setValue(_, topics) {
      if (topics.length) {
        this.set("field.value", topics);
      }
    },
  },
});
