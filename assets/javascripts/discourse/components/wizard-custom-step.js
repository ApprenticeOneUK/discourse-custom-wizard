/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action, computed } from "@ember/object";
import { classNames } from "@ember-decorators/component";

@classNames("wizard-custom-step")
export default class WizardCustomStep extends Component {
  @computed("step.index")
  get stepConditionOptions() {
    const options = {
      inputTypes: "validation",
      context: "step",
      textSelection: "value",
      userFieldSelection: true,
      groupSelection: true,
    };

    if (this.step.index > 0) {
      options.wizardFieldSelection = true;
      options.wizardActionSelection = true;
    }

    return options;
  }

  @action
  bannerUploadDone(upload) {
    this.setProperties({
      "step.banner": upload.url,
      "step.banner_upload_id": upload.id,
    });
  }

  @action
  bannerUploadDeleted() {
    this.setProperties({
      "step.banner": null,
      "step.banner_upload_id": null,
    });
  }
}
