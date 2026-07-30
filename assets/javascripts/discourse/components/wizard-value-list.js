import { optionalRequire } from "discourse/lib/utilities";

const ValueList = optionalRequire("admin/components/value-list");

let WizardValueList;

if (ValueList) {
  WizardValueList = class extends ValueList {
    _saveValues() {
      if (this.inputType === "array") {
        this.onChange(this.collection);
        return;
      }

      this.onChange(this.collection.join(this.inputDelimiter || "\n"));
    }
  };
}

export default WizardValueList;
