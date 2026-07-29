/* eslint-disable ember/no-actions-hash, ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";

export default Component.extend({
  actions: {
    perform() {
      this.appEvents.trigger("custom-wizard:validate");
    },
  },
});
