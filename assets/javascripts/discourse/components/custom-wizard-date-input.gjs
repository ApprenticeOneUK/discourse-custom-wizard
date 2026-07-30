import { Input } from "@ember/component";
import { on } from "@ember/modifier";
import DDateInput from "discourse/ui-kit/d-date-input";

export default class CustomWizardDateInput extends DDateInput {
  useNativePicker = false;

  get placeholder() {
    return this.format;
  }

  _opts() {
    return {
      format: this.format || "LL",
    };
  }

  <template>
    <Input
      @type={{this.inputType}}
      @value={{readonly this.value}}
      class="date-picker"
      placeholder={{this.placeholder}}
      tabindex={{this.tabindex}}
      {{on "input" this.onChangeDate}}
      autocomplete="off"
    />

    <div class="picker-container"></div>
  </template>
}
