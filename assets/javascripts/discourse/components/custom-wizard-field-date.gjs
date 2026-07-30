/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action } from "@ember/object";
import CustomWizardDateInput from "./custom-wizard-date-input";

export default class CustomWizardFieldDate extends Component {
  @action
  onChange(value) {
    const date = moment(value);
    this.setProperties({
      date,
      "field.value": date.format(this.field.format),
    });
  }

  <template>
    <CustomWizardDateInput
      @date={{this.date}}
      @onChange={{this.onChange}}
      @tabindex={{this.field.tabindex}}
      @format={{this.field.format}}
    />
  </template>
}
