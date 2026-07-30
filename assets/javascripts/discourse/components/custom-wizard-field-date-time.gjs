/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action } from "@ember/object";
import CustomWizardDateTimeInput from "./custom-wizard-date-time-input";

export default class CustomWizardFieldDateTime extends Component {
  @action
  onChange(value) {
    const dateTime = moment(value);
    this.setProperties({
      dateTime,
      "field.value": dateTime.format(this.field.format),
    });
  }

  <template>
    <CustomWizardDateTimeInput
      @date={{this.dateTime}}
      @onChange={{this.onChange}}
      @tabindex={{this.field.tabindex}}
    />
  </template>
}
