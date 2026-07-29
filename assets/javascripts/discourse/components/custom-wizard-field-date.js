/* eslint-disable discourse/discourse-common-imports, ember/no-actions-hash, ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { observes } from "discourse-common/utils/decorators";

export default Component.extend({
  @observes("date")
  setValue() {
    this.set("field.value", this.date.format(this.field.format));
  },

  actions: {
    onChange(value) {
      this.set("date", moment(value));
    },
  },
});
