import { computed } from "@ember/object";
import DDateTimeInput from "discourse/ui-kit/d-date-time-input";

export default class CustomWizardDateTimeInput extends DDateTimeInput {
  @computed("timeFirst", "tabindex")
  get timeTabindex() {
    return this.timeFirst ? this.tabindex : this.tabindex + 1;
  }

  @computed("timeFirst", "tabindex")
  get dateTabindex() {
    return this.timeFirst ? this.tabindex + 1 : this.tabindex;
  }
}
