/* eslint-disable ember/no-mixins */
import EmberObject, { computed } from "@ember/object";
import { later } from "@ember/runloop";
import { ajax } from "discourse/lib/ajax";
import { translationOrText } from "discourse/plugins/discourse-custom-wizard/discourse/lib/wizard";
import ValidState from "discourse/plugins/discourse-custom-wizard/discourse/mixins/valid-state";

export default class CustomWizardStep extends EmberObject.extend(ValidState) {
  id = null;

  @computed("wizardId", "id")
  get i18nKey() {
    return `${this.wizardId}.${this.id}`;
  }

  @computed("i18nKey", "title")
  get translatedTitle() {
    return translationOrText(`${this.i18nKey}.title`, this.title);
  }

  @computed("i18nKey", "description")
  get translatedDescription() {
    return translationOrText(`${this.i18nKey}.description`, this.description);
  }

  @computed("index")
  get displayIndex() {
    return this.index + 1;
  }

  @computed("fields.[]")
  get fieldsById() {
    const lookup = {};
    this.fields.forEach((field) => (lookup[field.get("id")] = field));
    return lookup;
  }

  validate() {
    let allValid = true;

    this.fields.forEach((field) => {
      allValid = allValid && field.check();
    });

    this.setValid(allValid);
  }

  fieldError(id, description) {
    const field = this.fields.find((item) => item.id === id);
    if (field) {
      field.setValid(false, description);
    }
  }

  save() {
    const wizardId = this.get("wizardId");
    const fields = {};

    this.get("fields").forEach((f) => {
      if (f.type !== "text_only") {
        fields[f.id] = f.value;
      }
    });

    return ajax({
      url: `/w/${wizardId}/steps/${this.get("id")}`,
      type: "PUT",
      contentType: "application/json",
      data: JSON.stringify({ fields }),
    }).catch((response) => {
      if (response.jqXHR) {
        response = response.jqXHR;
      }
      if (response && response.responseJSON && response.responseJSON.errors) {
        let wizardErrors = [];
        response.responseJSON.errors.forEach((err) => {
          if (err.field === wizardId) {
            wizardErrors.push(err.description);
          } else if (err.field) {
            this.fieldError(err.field, err.description);
          } else if (err) {
            wizardErrors.push(err);
          }
        });
        if (wizardErrors.length) {
          this.handleWizardError(wizardErrors.join("\n"));
        }
        this.animateInvalidFields();
        throw response;
      }

      if (response && response.responseText) {
        const responseText = response.responseText;
        const start = responseText.indexOf(">") + 1;
        const end = responseText.indexOf("plugins");
        const message = responseText.substring(start, end);
        this.handleWizardError(message);
        throw message;
      }
    });
  }

  handleWizardError(message) {
    this.set("message", {
      state: "error",
      text: message,
    });
    later(() => this.set("message", null), 6000);
  }
}
