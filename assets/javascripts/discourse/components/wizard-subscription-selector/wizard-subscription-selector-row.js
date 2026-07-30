import { computed } from "@ember/object";
import { classNameBindings } from "@ember-decorators/component";
import SelectKitRowComponent from "discourse/select-kit/components/select-kit/select-kit-row";

@classNameBindings("isDisabled:disabled")
export default class WizardSubscriptionSelectorRow extends SelectKitRowComponent {
  @computed("item")
  get isDisabled() {
    return this.item.disabled;
  }

  click(event) {
    event.preventDefault();
    event.stopPropagation();
    if (!this.item.disabled) {
      this.selectKit.select(this.rowValue, this.item);
    }
    return false;
  }
}
