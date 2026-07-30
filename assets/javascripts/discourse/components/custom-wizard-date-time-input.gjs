import { computed } from "@ember/object";
import DButton from "discourse/ui-kit/d-button";
import DDateTimeInput from "discourse/ui-kit/d-date-time-input";
import CustomWizardDateInput from "./custom-wizard-date-input";
import CustomWizardTimeInput from "./custom-wizard-time-input";

export default class CustomWizardDateTimeInput extends DDateTimeInput {
  @computed("timeFirst", "tabindex")
  get timeTabindex() {
    return this.timeFirst ? this.tabindex : this.tabindex + 1;
  }

  @computed("timeFirst", "tabindex")
  get dateTabindex() {
    return this.timeFirst ? this.tabindex + 1 : this.tabindex;
  }

  <template>
    {{#unless this.timeFirst}}
      <CustomWizardDateInput
        @date={{this.date}}
        @relativeDate={{this.relativeDate}}
        @onChange={{this.onChangeDate}}
        @tabindex={{this.dateTabindex}}
      />
    {{/unless}}

    {{#if this.showTime}}
      <CustomWizardTimeInput
        @date={{this.date}}
        @relativeDate={{this.relativeDate}}
        @onChange={{this.onChangeTime}}
        @tabindex={{this.timeTabindex}}
      />
    {{/if}}

    {{#if this.timeFirst}}
      <CustomWizardDateInput
        @date={{this.date}}
        @relativeDate={{this.relativeDate}}
        @onChange={{this.onChangeDate}}
        @tabindex={{this.dateTabindex}}
      />
    {{/if}}

    {{#if this.clearable}}
      <DButton class="clear-date-time" @icon="xmark" @action={{this.onClear}} />
    {{/if}}
  </template>
}
