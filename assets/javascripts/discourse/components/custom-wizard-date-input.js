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
}
