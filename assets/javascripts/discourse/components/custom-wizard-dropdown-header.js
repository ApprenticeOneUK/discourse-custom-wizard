import { computed } from "@ember/object";
import { attributeBindings } from "@ember-decorators/component";
import ComboBoxHeader from "discourse/select-kit/components/combo-box/combo-box-header";

@attributeBindings("ariaLabelledby:aria-labelledby")
export default class CustomWizardDropdownHeader extends ComboBoxHeader {
  get ariaLabel() {
    return null;
  }

  @computed("selectKit.options.headerAriaLabelledby")
  get ariaLabelledby() {
    return this.selectKit.options.headerAriaLabelledby;
  }
}
