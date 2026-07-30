import Controller from "@ember/controller";
import { action, computed } from "@ember/object";
import { later, scheduleOnce } from "@ember/runloop";
import { service } from "@ember/service";
import { dasherize } from "@ember/string";
import copyText from "discourse/lib/copy-text";
import { i18n } from "discourse-i18n";
import { filterValues } from "discourse/plugins/discourse-custom-wizard/discourse/lib/wizard-schema";
import NextSessionScheduledModal from "../components/modal/next-session-scheduled";
import { generateId, wizardFieldList } from "../lib/wizard";

export default class AdminWizardsWizardShowController extends Controller {
  @service modal;
  @service site;

  @computed("wizard.name")
  get hasName() {
    return Boolean(this.wizard?.name);
  }

  @action
  setCurrentStep(currentStep) {
    const fields = currentStep?.fields;
    this.setProperties({
      currentStep,
      currentField: fields?.length ? fields[0] : null,
    });
    scheduleOnce("afterRender", this, this._addBodyClass);
  }

  @action
  setCurrentField(currentField) {
    this.set("currentField", currentField);
  }

  @action
  setCurrentAction(currentAction) {
    this.set("currentAction", currentAction);
  }

  _addBodyClass() {
    document.body.classList.add("admin-wizard");
  }

  @action
  updateWizardName(event) {
    const wizard = this.wizard;
    const name = event.target.value;
    this.set("wizard.name", name);

    if (wizard && !wizard.existingId) {
      this.set("wizard.id", generateId(name));
    }
  }

  @computed("wizard.id")
  get wizardUrl() {
    const baseUrl = window.location.href.split("/admin");
    return `${baseUrl[0]}/w/${dasherize(this.wizard.id)}`;
  }

  @computed("wizard.after_time_scheduled")
  get nextSessionScheduledLabel() {
    return this.wizard.after_time_scheduled
      ? moment(this.wizard.after_time_scheduled).format("MMMM Do, HH:mm")
      : i18n("admin.wizard.after_time_time_label");
  }

  @computed(
    "currentStep.id",
    "wizard.save_submissions",
    "currentStep.fields.@each.label"
  )
  get wizardFields() {
    let steps = this.wizard.steps;
    if (!this.wizard.save_submissions) {
      steps = [steps.find((step) => step.id === this.currentStep.id)];
    }
    return wizardFieldList(steps);
  }

  @computed("fieldTypes", "wizard.allowGuests")
  get filteredFieldTypes() {
    const fieldTypeIds = this.fieldTypes.map((fieldType) => fieldType.id);
    const allowedTypeIds = filterValues(
      this.wizard,
      "field",
      "type",
      fieldTypeIds
    );
    return this.fieldTypes.filter((fieldType) =>
      allowedTypeIds.includes(fieldType.id)
    );
  }

  getErrorMessage(result) {
    if (result.backend_validation_error) {
      return result.backend_validation_error;
    }

    let errorType = "failed";
    let errorParams = {};

    if (result.error) {
      errorType = result.error.type;
      errorParams = result.error.params;
    }

    return i18n(`admin.wizard.error.${errorType}`, errorParams);
  }

  setAfterTimeGroupIds() {
    if (!this.wizard.after_time_groups) {
      return;
    }
    const groups = this.site.groups.filter((g) =>
      this.wizard.after_time_groups.includes(g.name)
    );
    this.setProperties({
      afterTimeGroupIds: groups.map((g) => g.id),
    });
  }

  @action
  setAfterTimeGroups(groupIds) {
    const groups = this.site.groups.filter((g) => groupIds.includes(g.id));
    this.setProperties({
      afterTimeGroupIds: groups.map((g) => g.id),
      "wizard.after_time_groups": groups.map((g) => g.name),
    });
  }

  @action
  updateThemeId(themeId) {
    this.set("wizard.theme_id", themeId);
  }

  @action
  save() {
    this.setProperties({
      saving: true,
      error: null,
    });

    const wizard = this.wizard;
    const opts = this.creating ? { create: true } : {};

    wizard
      .save(opts)
      .then((result) => {
        if (result.wizard_id) {
          this.send("afterSave", result.wizard_id);
        } else if (result.errors) {
          this.set("error", result.errors.join(", "));
        }
      })
      .catch((result) => {
        this.set("error", this.getErrorMessage(result));
        later(() => this.set("error", null), 10000);
      })
      .finally(() => this.set("saving", false));
  }

  @action
  remove() {
    this.wizard.remove().then(() => this.send("afterDestroy"));
  }

  @action
  setNextSessionScheduled() {
    this.modal.show(NextSessionScheduledModal, {
      model: {
        dateTime: this.wizard.after_time_scheduled,
        update: (dateTime) => this.set("wizard.after_time_scheduled", dateTime),
      },
    });
  }

  @action
  copyUrl() {
    const copyRange = document.createElement("p");
    copyRange.id = "copy-range";
    copyRange.textContent = this.wizardUrl;
    document.body.append(copyRange);

    if (copyText(this.wizardUrl, copyRange)) {
      this.set("copiedUrl", true);
      later(() => this.set("copiedUrl", false), 2000);
    }

    copyRange.remove();
  }
}
