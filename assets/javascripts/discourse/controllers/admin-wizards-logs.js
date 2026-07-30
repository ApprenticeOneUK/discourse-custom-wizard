import Controller from "@ember/controller";
import { computed } from "@ember/object";

export default class AdminWizardsLogsController extends Controller {
  documentationUrl =
    "https://pavilion.tech/products/discourse-custom-wizard-plugin/documentation/";

  @computed("wizardId")
  get wizardName() {
    const currentWizard = this.wizardList.find(
      (wizard) => wizard.id === this.wizardId
    );
    if (currentWizard) {
      return currentWizard.name;
    }
  }

  @computed("wizardName")
  get messageOpts() {
    return {
      wizardName: this.wizardName,
    };
  }

  @computed("wizardId")
  get messageKey() {
    return this.wizardId ? "viewing" : "select";
  }
}
