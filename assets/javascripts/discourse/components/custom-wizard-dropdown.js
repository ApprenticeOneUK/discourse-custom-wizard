import ComboBox from "discourse/select-kit/components/combo-box";
import { selectKitOptions } from "discourse/select-kit/components/select-kit";
import CustomWizardDropdownFilter from "./custom-wizard-dropdown-filter";
import CustomWizardDropdownHeader from "./custom-wizard-dropdown-header";

@selectKitOptions({
  filterAriaLabel: null,
  filterComponent: CustomWizardDropdownFilter,
  headerAriaLabelledby: null,
  headerComponent: CustomWizardDropdownHeader,
})
export default class CustomWizardDropdown extends ComboBox {}
