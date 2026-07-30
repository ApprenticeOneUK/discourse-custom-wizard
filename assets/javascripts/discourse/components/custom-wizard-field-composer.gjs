/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import EmberObject, { action, computed } from "@ember/object";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { classNameBindings } from "@ember-decorators/component";
import DButton from "discourse/ui-kit/d-button";
import wizardCharCounter from "../helpers/wizard-char-counter";
import CustomWizardComposerEditor from "./custom-wizard-composer-editor";

@classNameBindings(
  ":wizard-field-composer",
  "showPreview:show-preview:hide-preview"
)
export default class CustomWizardFieldComposer extends Component {
  showPreview = false;

  init() {
    super.init(...arguments);
    this.set(
      "composer",
      EmberObject.create({
        loading: false,
        model: {
          reply: this.get("field.value") || "",
        },
        afterRefresh: () => {},
        allowUpload: true,
      })
    );
  }

  @action
  setField() {
    this.set("field.value", this.get("composer.model.reply"));
  }

  @computed("showPreview")
  get togglePreviewLabel() {
    return this.showPreview
      ? "wizard_composer.hide_preview"
      : "wizard_composer.show_preview";
  }

  @action
  importQuote() {}

  @action
  groupsMentioned() {}

  @action
  afterRefresh() {}

  @action
  cannotSeeMention() {}

  @action
  showUploadSelector() {}

  @action
  togglePreview() {
    this.toggleProperty("showPreview");
  }

  <template>
    <CustomWizardComposerEditor
      @field={{this.field}}
      @composer={{this.composer}}
      @wizard={{this.wizard}}
      @fieldClass={{this.fieldClass}}
      @groupsMentioned={{this.groupsMentioned}}
      @cannotSeeMention={{this.cannotSeeMention}}
      @importQuote={{this.importQuote}}
      @togglePreview={{this.togglePreview}}
      @afterRefresh={{this.afterRefresh}}
    />

    <div
      class="bottom-bar"
      {{didUpdate this.setField this.composer.model.reply}}
    >
      <DButton
        @action={{this.togglePreview}}
        class="wizard-btn toggle-preview"
        @label={{this.togglePreviewLabel}}
      />

      {{#if this.field.char_counter}}
        {{wizardCharCounter this.field.value this.field.max_length}}
      {{/if}}
    </div>
  </template>
}
