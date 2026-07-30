import Controller from "@ember/controller";
import { computed } from "@ember/object";

const reasons = {
  noWizard: "none",
  requiresLogin: "requires_login",
  notPermitted: "not_permitted",
  completed: "completed",
};

export default class CustomWizardIndex extends Controller {
  @computed("noWizard", "requiresLogin", "notPermitted", "completed")
  get noAccess() {
    return (
      this.noWizard || this.requiresLogin || this.notPermitted || this.completed
    );
  }

  @computed("noAccessReason")
  get noAccessI18nKey() {
    return this.noAccessReason
      ? `wizard.${reasons[this.noAccessReason]}`
      : "wizard.none";
  }

  get noAccessReason() {
    return Object.keys(reasons).find((reason) => this.get(reason));
  }
}
