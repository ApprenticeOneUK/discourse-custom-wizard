/* eslint-disable ember/no-actions-hash, ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { observes } from "discourse/lib/decorators";

export default Component.extend({
  classNameBindings: ["fieldClass"],

  @observes("time")
  setValue() {
    this.set("field.value", this.time.format(this.field.format));
  },

  actions: {
    onChange(value) {
      this.set(
        "time",
        moment({
          hours: value.hours,
          minutes: value.minutes,
        })
      );
    },
  },
});
