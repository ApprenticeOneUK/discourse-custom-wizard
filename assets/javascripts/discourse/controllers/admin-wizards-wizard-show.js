/* eslint-disable ember/no-actions-hash, ember/no-classic-classes */
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { notEmpty } from "@ember/object/computed";
import { later, scheduleOnce } from "@ember/runloop";
import { service } from "@ember/service";
import { dasherize } from "@ember/string";
import copyText from "discourse/lib/copy-text";
import {
  default as discourseComputed,
  observes,
} from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { filterValues } from "discourse/plugins/discourse-custom-wizard/discourse/lib/wizard-schema";
import NextSessionScheduledModal from "../components/modal/next-session-scheduled";
import { generateId, wizardFieldList } from "../lib/wizard";

export default Controller.extend({
  modal: service(),
  site: service(),
  hasName: notEmpty("wizard.name"),

  @observes("currentStep")
  resetCurrentObjects() {
    const currentStep = this.currentStep;

    if (currentStep) {
      const fields = currentStep.fields;
      this.set("currentField", fields && fields.length ? fields[0] : null);
    }

    scheduleOnce("afterRender", this, this._addBodyClass);
  },

  _addBodyClass() {
    document.body.classList.add("admin-wizard");
  },

  @observes("wizard.name")
  setId() {
    const wizard = this.wizard;
    if (wizard && !wizard.existingId) {
      this.set("wizard.id", generateId(wizard.name));
    }
  },

  @discourseComputed("wizard.id")
  wizardUrl(wizardId) {
    let baseUrl = window.location.href.split("/admin");
    return baseUrl[0] + "/w/" + dasherize(wizardId);
  },

  @discourseComputed("wizard.after_time_scheduled")
  nextSessionScheduledLabel(scheduled) {
    return scheduled
      ? moment(scheduled).format("MMMM Do, HH:mm")
      : i18n("admin.wizard.after_time_time_label");
  },

  @discourseComputed(
    "currentStep.id",
    "wizard.save_submissions",
    "currentStep.fields.@each.label"
  )
  wizardFields(currentStepId, saveSubmissions) {
    let steps = this.wizard.steps;
    if (!saveSubmissions) {
      steps = [steps.find((step) => step.id === currentStepId)];
    }
    return wizardFieldList(steps);
  },

  @discourseComputed("fieldTypes", "wizard.allowGuests")
  filteredFieldTypes(fieldTypes) {
    const fieldTypeIds = fieldTypes.map((f) => f.id);
    const allowedTypeIds = filterValues(
      this.wizard,
      "field",
      "type",
      fieldTypeIds
    );
    return fieldTypes.filter((f) => allowedTypeIds.includes(f.id));
  },

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
  },

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
  },

  @action
  setAfterTimeGroups(groupIds) {
    const groups = this.site.groups.filter((g) => groupIds.includes(g.id));
    this.setProperties({
      afterTimeGroupIds: groups.map((g) => g.id),
      "wizard.after_time_groups": groups.map((g) => g.name),
    });
  },

  actions: {
    save() {
      this.setProperties({
        saving: true,
        error: null,
      });

      const wizard = this.wizard;
      const creating = this.creating;
      let opts = {};

      if (creating) {
        opts.create = true;
      }

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
    },

    remove() {
      this.wizard.remove().then(() => this.send("afterDestroy"));
    },

    setNextSessionScheduled() {
      this.modal.show(NextSessionScheduledModal, {
        model: {
          dateTime: this.wizard.after_time_scheduled,
          update: (dateTime) =>
            this.set("wizard.after_time_scheduled", dateTime),
        },
      });
    },

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
    },
  },
});
