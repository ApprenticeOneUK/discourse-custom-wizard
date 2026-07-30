import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";
import { i18n } from "discourse-i18n";
import CustomWizardAdmin from "../models/custom-wizard-admin";

export default DiscourseRoute.extend({
  router: service(),

  model(params) {
    if (params.wizardId === "create") {
      return { create: true };
    } else {
      return ajax(`/admin/wizards/wizard/${params.wizardId}`);
    }
  },

  afterModel(model) {
    if (model.none) {
      return this.router.transitionTo("adminWizardsWizard");
    }
  },

  setupController(controller, model) {
    const parentModel = this.modelFor("adminWizardsWizard");
    const wizard = CustomWizardAdmin.create(
      !model || model.create ? {} : model
    );
    const fieldTypes = Object.keys(parentModel.field_types).map((type) => {
      return {
        id: type,
        name: i18n(`admin.wizard.field.type.${type}`),
      };
    });

    let props = {
      wizardList: parentModel.wizard_list,
      fieldTypes,
      userFields: parentModel.userFields,
      customFields: parentModel.custom_fields,
      apis: parentModel.apis,
      themes: parentModel.themes,
      wizard,
      creating: model.create,
      afterTimeGroupIds: [],
    };

    controller.setProperties(props);
    controller.setCurrentStep(wizard.steps[0]);
    controller.setCurrentAction(wizard.actions[0]);
    controller.setAfterTimeGroupIds();
  },
});
