/* eslint-disable ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { not, notEmpty } from "@ember/object/computed";
import { default as discourseComputed } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";

const icons = {
  error: "circle-xmark",
  success: "circle-check",
  warn: "exclamation-circle",
  info: "circle-info",
};

export default Component.extend({
  classNameBindings: [":wizard-message", "type", "loading"],
  showDocumentation: not("loading"),
  showIcon: not("loading"),
  hasItems: notEmpty("items"),

  @discourseComputed("type")
  icon(type) {
    return icons[type] || "circle-info";
  },

  @discourseComputed("key", "component", "opts")
  message(key, component, opts) {
    return i18n(`admin.wizard.message.${component}.${key}`, opts || {});
  },

  @discourseComputed("component")
  documentation(component) {
    return i18n(`admin.wizard.message.${component}.documentation`);
  },
});
