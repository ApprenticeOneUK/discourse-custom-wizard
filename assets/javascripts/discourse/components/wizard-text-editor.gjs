/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action, computed } from "@ember/object";
import { scheduleOnce } from "@ember/runloop";
import { classNames } from "@ember-decorators/component";
import DButton from "discourse/ui-kit/d-button";
import DEditor from "discourse/ui-kit/d-editor";
import { i18n, i18n as i18n0 } from "discourse-i18n";
import { userProperties } from "../lib/wizard";

const excludedUserProperties = ["profile_background", "card_background"];

@classNames("wizard-text-editor")
export default class WizardTextEditor extends Component {
  barEnabled = true;
  previewEnabled = true;
  fieldsEnabled = true;

  @computed("wizardFieldList.[]")
  get hasWizardFields() {
    return Boolean(this.wizardFieldList.length);
  }

  @computed("wizardActionList.[]")
  get hasWizardActions() {
    return Boolean(this.wizardActionList.length);
  }

  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);

    if (!this.barEnabled) {
      scheduleOnce("afterRender", this, this._hideButtonBar);
    }
  }

  _hideButtonBar() {
    this.element.querySelector(".d-editor-button-bar")?.classList.add("hidden");
  }

  @computed("forcePreview")
  get previewLabel() {
    return i18n("admin.wizard.editor.preview", {
      action: i18n(
        `admin.wizard.editor.${this.forcePreview ? "hide" : "show"}`
      ),
    });
  }

  @computed("showPopover")
  get popoverLabel() {
    return i18n("admin.wizard.editor.popover", {
      action: i18n(`admin.wizard.editor.${this.showPopover ? "hide" : "show"}`),
    });
  }

  get userPropertyList() {
    return userProperties
      .filter((f) => !excludedUserProperties.includes(f))
      .map((f) => ` u{${f}}`);
  }

  @computed("wizardFields")
  get wizardFieldList() {
    return (this.wizardFields || []).map((field) => ` w{${field.id}}`);
  }

  @computed("wizardActions")
  get wizardActionList() {
    return (this.wizardActions || []).map((actionItem) => {
      return ` w{${actionItem.id}}`;
    });
  }

  @action
  togglePreview() {
    this.toggleProperty("forcePreview");
  }

  @action
  togglePopover() {
    this.toggleProperty("showPopover");
  }

  <template>
    <DEditor
      @value={{this.value}}
      @forcePreview={{this.forcePreview}}
      @placeholder={{this.placeholder}}
    />

    <div class="wizard-editor-gutter">
      {{#if this.previewEnabled}}
        <DButton
          @action={{this.togglePreview}}
          @translatedLabel={{this.previewLabel}}
        />
      {{/if}}

      {{#if this.fieldsEnabled}}
        <DButton
          @action={{this.togglePopover}}
          @translatedLabel={{this.popoverLabel}}
        />

        {{#if this.showPopover}}
          <div class="wizard-editor-gutter-popover">
            <label>
              {{i18n0 "admin.wizard.action.post_builder.user_properties"}}
              {{this.userPropertyList}}
            </label>

            {{#if this.hasWizardFields}}
              <label>
                {{i18n0 "admin.wizard.action.post_builder.wizard_fields"}}
                {{this.wizardFieldList}}
              </label>
            {{/if}}

            {{#if this.hasWizardActions}}
              <label>
                {{i18n0 "admin.wizard.action.post_builder.wizard_actions"}}
                {{this.wizardActionList}}
              </label>
            {{/if}}
          </div>
        {{/if}}
      {{/if}}
    </div>
  </template>
}
