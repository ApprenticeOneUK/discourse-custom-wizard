import Controller from "@ember/controller";
import { action } from "@ember/object";
import { autoTrackedArray } from "discourse/lib/tracked-tools";
import CustomWizardCustomField from "../models/custom-wizard-custom-field";

export default class AdminWizardsCustomFields extends Controller {
  @autoTrackedArray customFields;

  messageKey = "create";
  fieldKeys = ["klass", "type", "name", "serializers"];
  documentationUrl =
    "https://pavilion.tech/products/discourse-custom-wizard-plugin/documentation/custom-fields";

  @action
  addField() {
    this.customFields.unshift(CustomWizardCustomField.create({ edit: true }));
  }

  @action
  saveField(field) {
    return CustomWizardCustomField.saveField(field).then((result) => {
      if (result.success) {
        this.setProperties({
          messageKey: "saved",
          messageType: "success",
        });
      } else {
        if (result.messages) {
          this.setProperties({
            messageKey: "error",
            messageType: "error",
            messageOpts: { messages: result.messages },
          });
        }
      }

      setTimeout(() => {
        if (this.isDestroyed) {
          return;
        }
        this.setProperties({
          messageKey: "create",
          messageType: null,
          messageOpts: null,
        });
      }, 10000);

      return result;
    });
  }

  @action
  removeField(field) {
    return CustomWizardCustomField.destroyField(field).then(() => {
      const index = this.customFields.indexOf(field);
      if (index !== -1) {
        this.customFields.splice(index, 1);
      }
    });
  }
}
