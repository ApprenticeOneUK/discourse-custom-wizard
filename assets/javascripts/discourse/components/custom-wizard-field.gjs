/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action, computed } from "@ember/object";
import { getOwner } from "@ember/owner";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { dasherize } from "@ember/string";
import { trustHTML } from "@ember/template";
import { classNameBindings } from "@ember-decorators/component";
import { cook } from "discourse/lib/text";
import wizardCharCounter from "../helpers/wizard-char-counter";
import FieldValidators from "./field-validators";

@classNameBindings(":wizard-field", "typeClasses", "field.invalid", "field.id")
export default class CustomWizardField extends Component {
  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);

    cook(this.field.translatedDescription).then((cookedDescription) => {
      this.set("cookedDescription", cookedDescription);
    });
  }

  @computed("field.type", "field.id")
  get typeClasses() {
    const type = dasherize(this.field.type);
    return `${type}-field ${type}-${dasherize(this.field.id)}`;
  }

  @computed("field.id")
  get fieldClass() {
    return `field-${dasherize(this.field.id)} wizard-focusable`;
  }

  @computed("field.{wizardId,stepId,id}")
  get fieldLabelId() {
    const fieldPath = [this.field.wizardId, this.field.stepId, this.field.id]
      .filter(Boolean)
      .map((part) => dasherize(part))
      .join("-");

    return `wizard-field-${fieldPath}-label`;
  }

  @computed("field.type", "field.id")
  get inputComponentName() {
    if (this.field.type === "text_only") {
      return false;
    }
    return dasherize(
      this.field.type === "component"
        ? this.field.id
        : `custom-wizard-field-${this.field.type}`
    );
  }

  @computed("inputComponentName")
  get inputComponent() {
    if (!this.inputComponentName) {
      return;
    }

    return getOwner(this).resolveRegistration(
      `component:${this.inputComponentName}`
    );
  }

  @computed("field.type")
  get textType() {
    return ["text", "textarea"].includes(this.field.type);
  }

  @action
  fieldValueChanged() {
    if (this.field.requiredErrorActive && this.field.hasRequiredValue()) {
      this.field.set("requiredErrorActive", false);
      this.field.setValid(true);
    }
  }

  <template>
    <label id={{this.fieldLabelId}} for={{this.field.id}} class="field-label">
      {{trustHTML this.field.translatedLabel}}
    </label>

    {{#if this.field.image}}
      <div class="field-image"><img src={{this.field.image}} /></div>
    {{/if}}

    {{#if this.field.description}}
      <div class="field-description">{{this.cookedDescription}}</div>
    {{/if}}

    <FieldValidators @field={{this.field}} as |validators|>
      {{#if this.inputComponent}}
        <div
          class="input-area"
          {{didUpdate this.fieldValueChanged this.field.value}}
        >
          <this.inputComponent
            @field={{this.field}}
            @step={{this.step}}
            @fieldClass={{this.fieldClass}}
            @fieldLabelId={{this.fieldLabelId}}
            @wizard={{this.wizard}}
            @autocomplete={{validators.autocomplete}}
          />
        </div>
      {{/if}}
    </FieldValidators>

    {{#if this.field.char_counter}}
      {{#if this.textType}}
        {{wizardCharCounter this.field.value this.field.max_length}}
      {{/if}}
    {{/if}}

    {{#if this.field.errorDescription}}
      <div class="field-error-description" role="alert" aria-atomic="true">
        {{trustHTML this.field.errorDescription}}
      </div>
    {{/if}}
  </template>
}
