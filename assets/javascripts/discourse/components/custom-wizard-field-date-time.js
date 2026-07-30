/* eslint-disable ember/no-actions-hash, ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { observes } from "discourse/lib/decorators";

export default Component.extend({
  @observes("dateTime")
  setValue() {
    this.set("field.value", this.dateTime.format(this.field.format));
  },

  actions: {
    onChange(value) {
      this.set("dateTime", moment(value));
    },
  },
});
