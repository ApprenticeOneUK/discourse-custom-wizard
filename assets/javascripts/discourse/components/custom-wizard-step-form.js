/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { computed } from "@ember/object";
import { classNameBindings } from "@ember-decorators/component";

@classNameBindings(":wizard-step-form", "customStepClass")
export default class CustomWizardStepForm extends Component {
  @computed("step.id")
  get customStepClass() {
    return `wizard-step-${this.step.id}`;
  }
}
