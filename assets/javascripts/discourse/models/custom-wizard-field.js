/* eslint-disable ember/no-mixins */
import EmberObject, { computed } from "@ember/object";
import { translationOrText } from "discourse/plugins/discourse-custom-wizard/discourse/lib/wizard";
import ValidState from "discourse/plugins/discourse-custom-wizard/discourse/mixins/valid-state";

const StandardFieldValidation = [
  "text",
  "number",
  "textarea",
  "dropdown",
  "tag",
  "image",
  "user_selector",
  "text_only",
  "composer",
  "category",
  "topic",
  "group",
  "date",
  "time",
  "date_time",
];

export default class CustomWizardField extends EmberObject.extend(ValidState) {
  id = null;
  type = null;
  value = null;
  required = null;
  requiredErrorActive = false;

  @computed("wizardId", "stepId", "id")
  get i18nKey() {
    return `${this.wizardId}.${this.stepId}.${this.id}`;
  }

  @computed("i18nKey", "label")
  get translatedLabel() {
    return translationOrText(`${this.i18nKey}.label`, this.label);
  }

  @computed("i18nKey", "placeholder")
  get translatedPlaceholder() {
    return translationOrText(`${this.i18nKey}.placeholder`, this.placeholder);
  }

  @computed("i18nKey", "description")
  get translatedDescription() {
    return translationOrText(`${this.i18nKey}.description`, this.description);
  }

  hasRequiredValue() {
    const val = this.get("value");
    const type = this.get("type");

    if (type === "checkbox") {
      return Boolean(val);
    } else if (type === "upload") {
      return Boolean(val && val.id > 0);
    } else if (StandardFieldValidation.includes(type)) {
      return Boolean(val && val.toString().length > 0);
    } else if (type === "url") {
      return true;
    }

    return this.valid;
  }

  requiredErrorDescription(messages) {
    return messages[this.type] || messages.default;
  }

  check(requiredErrorMessages = {}) {
    if (this.customCheck) {
      return this.customCheck();
    }

    if (!this.required) {
      this.set("requiredErrorActive", false);
      this.setValid(true);
      return true;
    }

    const valid = this.hasRequiredValue();
    this.set("requiredErrorActive", !valid);
    const description = valid
      ? null
      : this.requiredErrorDescription(requiredErrorMessages);

    this.setValid(valid, description);

    return valid;
  }
}
