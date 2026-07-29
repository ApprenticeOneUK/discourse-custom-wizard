/* eslint-disable discourse/discourse-common-imports, ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  classNameBindings: [":wizard-step-form", "customStepClass"],

  @discourseComputed("step.id")
  customStepClass: (stepId) => `wizard-step-${stepId}`,
});
