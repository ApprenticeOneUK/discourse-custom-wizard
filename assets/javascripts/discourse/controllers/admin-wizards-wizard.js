import Controller from "@ember/controller";
import { computed } from "@ember/object";

export default class AdminWizardsWizardController extends Controller {
  messageUrl =
    "https://pavilion.tech/products/discourse-custom-wizard-plugin/documentation/";

  @computed("wizardId")
  get creating() {
    return this.wizardId === "create";
  }

  @computed("creating", "wizardId")
  get wizardListVal() {
    return this.creating ? null : this.wizardId;
  }

  @computed("creating", "wizardId")
  get messageKey() {
    if (this.creating) {
      return "create";
    }
    return this.wizardId ? "edit" : "select";
  }
}
