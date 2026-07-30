/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component, { Input } from "@ember/component";
import { concat, hash } from "@ember/helper";
import { action, computed } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import UppyImageUploader from "discourse/components/uppy-image-uploader";
import { i18n } from "discourse-i18n";
import WizardCustomField from "./wizard-custom-field";
import WizardLinks from "./wizard-links";
import WizardMapper from "./wizard-mapper";
import WizardTextEditor from "./wizard-text-editor";

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

  <template>
    <div class="setting">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.step.title"}}</label>
      </div>
      <div class="setting-value">
        <Input name="title" @value={{this.step.title}} />
      </div>
    </div>

    <div class="setting full">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.step.banner"}}</label>
      </div>
      <div class="setting-value">
        <UppyImageUploader
          @imageUrl={{this.step.banner}}
          @onUploadDone={{this.bannerUploadDone}}
          @onUploadDeleted={{this.bannerUploadDeleted}}
          @type="wizard-step-banner"
          class="no-repeat contain-image"
          @id={{concat "wizard-step-" this.step.id "-banner-upload"}}
        />
      </div>
    </div>

    <div class="setting full">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.step.description"}}</label>
      </div>
      <div class="setting-value">
        <WizardTextEditor @value={{this.step.raw_description}} />
      </div>
    </div>

    <div class="setting full field-mapper-setting">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.condition"}}</label>
      </div>

      <div class="setting-value">
        <WizardMapper
          @inputs={{this.step.condition}}
          @options={{this.stepConditionOptions}}
        />
      </div>
    </div>

    <div class="setting full">
      <div class="setting-label"></div>
      <div class="setting-value force-final">
        <h4>{{i18n "admin.wizard.step.force_final.label"}}</h4>
        <Input @type="checkbox" @checked={{this.step.force_final}} />
        <span>{{i18n "admin.wizard.step.force_final.description"}}</span>
      </div>
    </div>

    <div class="setting full field-mapper-setting">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.step.required_data.label"}}</label>
      </div>

      <div class="setting-value">
        <WizardMapper
          @inputs={{this.step.required_data}}
          @options={{hash
            inputTypes="validation"
            inputConnector="and"
            wizardFieldSelection="value"
            userFieldSelection="value"
            keyPlaceholder="admin.wizard.submission_key"
            context="step"
          }}
        />
        {{#if this.step.required_data}}
          <div class="required-data-message">
            <div class="label">
              {{i18n "admin.wizard.step.required_data.not_permitted_message"}}
            </div>
            <Input @value={{this.step.required_data_message}} />
          </div>
        {{/if}}
      </div>
    </div>

    <div class="setting full field-mapper-setting">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.step.permitted_params.label"}}</label>
      </div>
      <div class="setting-value">
        <WizardMapper
          @inputs={{this.step.permitted_params}}
          @options={{hash
            pairConnector="set"
            inputTypes="association"
            keyPlaceholder="admin.wizard.param_key"
            valuePlaceholder="admin.wizard.submission_key"
            context="step"
          }}
        />
      </div>
    </div>

    <WizardLinks
      @itemType="field"
      @current={{this.currentField}}
      @items={{this.step.fields}}
      @parentId={{this.step.id}}
      @onChange={{this.setCurrentField}}
    />

    {{#each this.step.fields as |field|}}
      <WizardCustomField
        @field={{field}}
        @step={{this.step}}
        @wizard={{this.wizard}}
        @currentFieldId={{this.currentField.id}}
        @fieldTypes={{this.fieldTypes}}
        @removeField="removeField"
        @wizardFields={{this.wizardFields}}
        @subscribed={{this.subscribed}}
      />
    {{/each}}
  </template>
}
