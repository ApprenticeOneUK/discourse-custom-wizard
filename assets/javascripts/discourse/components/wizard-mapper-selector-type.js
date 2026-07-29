/* eslint-disable discourse/discourse-common-imports, ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  tagName: "a",
  classNameBindings: ["active"],

  @discourseComputed("item.type", "activeType")
  active(type, activeType) {
    return type === activeType;
  },

  click() {
    this.toggle(this.item.type);
  },
});
