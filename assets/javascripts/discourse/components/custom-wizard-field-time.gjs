/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action } from "@ember/object";
import { classNameBindings } from "@ember-decorators/component";
import CustomWizardTimeInput from "./custom-wizard-time-input";

@classNameBindings("fieldClass")
export default class CustomWizardFieldTime extends Component {
  @action
  onChange(value) {
    const time = moment({
      hours: value.hours,
      minutes: value.minutes,
    });
    this.setProperties({
      time,
      "field.value": time.format(this.field.format),
    });
  }

  <template>
    <CustomWizardTimeInput
      @date={{this.time}}
      @onChange={{this.onChange}}
      @tabindex={{this.field.tabindex}}
    />
  </template>
}
