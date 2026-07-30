/* eslint-disable ember/no-actions-hash, ember/no-classic-classes, ember/no-classic-components, ember/no-mixins, ember/require-tagless-components */
import Component, { Input, Textarea } from "@ember/component";
import { concat, hash } from "@ember/helper";
import { action, computed } from "@ember/object";
import { equal, or } from "@ember/object/computed";
import { trustHTML } from "@ember/template";
import UppyImageUploader from "discourse/components/uppy-image-uploader";
import CategoryChooser from "discourse/select-kit/components/category-chooser";
import ComboBox from "discourse/select-kit/components/combo-box";
import TagGroupChooser from "discourse/select-kit/components/tag-group-chooser";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import { selectKitContent } from "../lib/wizard";
import wizardSchema from "../lib/wizard-schema";
import UndoChanges from "../mixins/undo-changes";
import WizardMapper from "./wizard-mapper";
import WizardMessage from "./wizard-message";
import WizardRealtimeValidations from "./wizard-realtime-validations";
import WizardSubscriptionSelector from "./wizard-subscription-selector";

const WizardCustomField = Component.extend(UndoChanges, {
  componentType: "field",
  classNameBindings: [":wizard-custom-field", "visible"],
  visible: computed("currentFieldId", function () {
    return this.field.id === this.currentFieldId;
  }),
  isDropdown: equal("field.type", "dropdown"),
  isUpload: equal("field.type", "upload"),
  isCategory: equal("field.type", "category"),
  isTopic: equal("field.type", "topic"),
  isGroup: equal("field.type", "group"),
  isTag: equal("field.type", "tag"),
  isText: equal("field.type", "text"),
  isTextarea: equal("field.type", "textarea"),
  isUrl: equal("field.type", "url"),
  isComposer: equal("field.type", "composer"),
  showPrefill: or(
    "isText",
    "isCategory",
    "isTag",
    "isGroup",
    "isDropdown",
    "isTopic"
  ),
  showContent: or("isCategory", "isTag", "isGroup", "isDropdown", "isTopic"),
  showLimit: or("isCategory", "isTag", "isTopic"),
  isTextType: or("isText", "isTextarea", "isComposer"),
  isComposerPreview: equal("field.type", "composer_preview"),
  categoryPropertyTypes: selectKitContent(["id", "slug"]),
  messageUrl:
    "https://pavilion.tech/products/discourse-custom-wizard-plugin/documentation/field-settings",

  validations: computed("field.type", function () {
    const type = this.field.type;
    const applicableToField = [];

    for (let validation in wizardSchema.field.validations) {
      if (wizardSchema.field.validations[validation]["types"].includes(type)) {
        applicableToField.push(validation);
      }
    }

    return applicableToField;
  }),

  isDateTime: computed("field.type", function () {
    return ["date_time", "date", "time"].includes(this.field.type);
  }),

  messageKey: computed("field.type", function () {
    let key = "type";
    if (this.field.type) {
      key = "edit";
    }
    return key;
  }),

  setupTypeOutput(fieldType, options) {
    const selectionType = {
      category: "category",
      tag: "tag",
      group: "group",
    }[fieldType];

    if (selectionType) {
      options[`${selectionType}Selection`] = "output";
      options.outputDefaultSelection = selectionType;
    }

    return options;
  },

  contentOptions: computed("field.type", function () {
    const fieldType = this.field.type;
    let options = {
      wizardFieldSelection: true,
      textSelection: "key,value",
      userFieldSelection: "key,value",
      context: "field",
    };

    options = this.setupTypeOutput(fieldType, options);

    if (this.isDropdown) {
      options.wizardFieldSelection = "key,value";
      options.userFieldOptionsSelection = "output";
      options.textSelection = "key,value";
      options.inputTypes = "association,conditional,assignment";
      options.pairConnector = "association";
      options.keyPlaceholder = "admin.wizard.key";
      options.valuePlaceholder = "admin.wizard.value";
    }

    return options;
  }),

  prefillOptions: computed("field.type", function () {
    const fieldType = this.field.type;
    let options = {
      wizardFieldSelection: true,
      textSelection: true,
      userFieldSelection: "key,value",
      context: "field",
    };

    return this.setupTypeOutput(fieldType, options);
  }),

  fieldConditionOptions: computed("step.index", function () {
    const stepIndex = this.step.index;
    const options = {
      inputTypes: "validation",
      context: "field",
      textSelection: "value",
      userFieldSelection: true,
      groupSelection: true,
    };

    if (stepIndex > 0) {
      options.wizardFieldSelection = true;
      options.wizardActionSelection = true;
    }

    return options;
  }),

  fieldIndexOptions: computed("step.index", function () {
    const stepIndex = this.step.index;
    const options = {
      context: "field",
      userFieldSelection: true,
      groupSelection: true,
    };

    if (stepIndex > 0) {
      options.wizardFieldSelection = true;
      options.wizardActionSelection = true;
    }

    return options;
  }),

  actions: {
    imageUploadDone(upload) {
      this.setProperties({
        "field.image": upload.url,
        "field.image_upload_id": upload.id,
      });
    },

    imageUploadDeleted() {
      this.setProperties({
        "field.image": null,
        "field.image_upload_id": null,
      });
    },

    changeCategory(category) {
      this.set("field.category", category?.id);
    },
  },
});

export default class WizardCustomFieldComponent extends WizardCustomField {
  @action
  handleUndoChanges() {
    this.send("undoChanges");
  }

  @action
  handleImageUploadDone(upload) {
    this.send("imageUploadDone", upload);
  }

  @action
  handleImageUploadDeleted() {
    this.send("imageUploadDeleted");
  }

  @action
  handleChangeType(type) {
    this.send("changeType", type);
  }

  @action
  handleMappedFieldUpdated(...args) {
    this.send("mappedFieldUpdated", ...args);
  }

  @action
  handleChangeCategory(category) {
    this.send("changeCategory", category);
  }

  @action
  updateTagGroups(tagGroups) {
    this.set("field.tag_groups", tagGroups);
  }

  @action
  updateFieldProperty(property) {
    this.set("field.property", property);
  }

  <template>
    {{#if this.showUndo}}
      <DButton
        @action={{this.handleUndoChanges}}
        @icon={{this.undoIcon}}
        @label={{this.undoKey}}
        class="undo-changes"
      />
    {{/if}}

    <div class="setting">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.field.label"}}</label>
      </div>
      <div class="setting-value">
        <Input name="label" @value={{this.field.label}} />
      </div>
    </div>

    <div class="setting">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.field.required"}}</label>
      </div>

      <div class="setting-value">
        <span>{{i18n "admin.wizard.field.required_label"}}</span>
        <Input @type="checkbox" @checked={{this.field.required}} />
      </div>
    </div>

    <div class="setting">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.field.description"}}</label>
      </div>
      <div class="setting-value">
        <Textarea name="description" @value={{this.field.description}} />
      </div>
    </div>

    <div class="setting">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.field.image"}}</label>
      </div>
      <div class="setting-value">
        <UppyImageUploader
          @imageUrl={{this.field.image}}
          @onUploadDone={{this.handleImageUploadDone}}
          @onUploadDeleted={{this.handleImageUploadDeleted}}
          @type="wizard-field-image"
          @id={{concat "wizard-field-" this.field.id "-image-upload"}}
          class="no-repeat contain-image"
        />
      </div>
    </div>

    <div class="setting">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.type"}}</label>
      </div>

      <div class="setting-value">
        <WizardSubscriptionSelector
          @value={{this.field.type}}
          @feature="field"
          @attribute="type"
          @onChange={{this.handleChangeType}}
          @wizard={{this.wizard}}
          @options={{hash none="admin.wizard.select_type"}}
        />
      </div>
    </div>

    <WizardMessage
      @key={{this.messageKey}}
      @url={{this.messageUrl}}
      @component="field"
    />

    {{#if this.isTextType}}
      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.min_length"}}</label>
        </div>

        <div class="setting-value">
          <Input
            @type="number"
            name="min_length"
            @value={{this.field.min_length}}
            class="small"
          />
        </div>
      </div>

      <div class="setting full">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.max_length"}}</label>
        </div>

        <div class="setting-value">
          <Input
            @type="number"
            name="max_length"
            @value={{this.field.max_length}}
            class="small"
          />
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.char_counter"}}</label>
        </div>

        <div class="setting-value">
          <span>{{i18n "admin.wizard.field.char_counter_placeholder"}}</span>
          <Input @type="checkbox" @checked={{this.field.char_counter}} />
        </div>
      </div>

      <div class="setting full">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.field_placeholder"}}</label>
        </div>

        <div class="setting-value">
          <Textarea
            name="field_placeholder"
            class="medium"
            @value={{this.field.placeholder}}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.isComposerPreview}}
      <div class="setting full">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.preview_template"}}</label>
        </div>

        <div class="setting-value">
          <Textarea
            name="preview-template"
            class="preview-template"
            @value={{this.field.preview_template}}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.isUpload}}
      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.file_types"}}</label>
        </div>

        <div class="setting-value">
          <Input @value={{this.field.file_types}} class="medium" />
        </div>
      </div>
    {{/if}}

    {{#if this.showLimit}}
      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.limit"}}</label>
        </div>

        <div class="setting-value">
          <Input @type="number" @value={{this.field.limit}} class="small" />
        </div>
      </div>
    {{/if}}

    {{#if this.isDateTime}}
      <div class="setting">
        <div class="setting-label">
          <label>
            {{trustHTML (i18n "admin.wizard.field.date_time_format.label")}}
          </label>
        </div>

        <div class="setting-value">
          <Input @value={{this.field.format}} class="medium" />
          <label>
            {{trustHTML
              (i18n "admin.wizard.field.date_time_format.instructions")
            }}
          </label>
        </div>
      </div>
    {{/if}}

    {{#if this.showPrefill}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.prefill"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.field.prefill}}
            @property="prefill"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{this.prefillOptions}}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.showContent}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.content"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.field.content}}
            @property="content"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{this.contentOptions}}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.isTag}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.tag_groups"}}</label>
        </div>

        <div class="setting-value">
          <TagGroupChooser
            @id={{concat this.field.id "-tag-groups"}}
            @tagGroups={{this.field.tag_groups}}
            @onChange={{this.updateTagGroups}}
          />
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.can_create_tag"}}</label>
        </div>

        <div class="setting-value">
          <Input @type="checkbox" @checked={{this.field.can_create_tag}} />
        </div>
      </div>
    {{/if}}

    {{#if this.isTopic}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.category.label"}}</label>
        </div>

        <div class="setting-value">
          <CategoryChooser
            @value={{this.field.category}}
            @onChangeCategory={{this.handleChangeCategory}}
            @options={{hash
              none="admin.wizard.field.category.none"
              autoInsertNoneItem=true
            }}
          />
        </div>
      </div>
    {{/if}}

    <div class="setting full field-mapper-setting">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.condition"}}</label>
      </div>

      <div class="setting-value">
        <WizardMapper
          @inputs={{this.field.condition}}
          @options={{this.fieldConditionOptions}}
        />
      </div>
    </div>

    <div class="setting full field-mapper-setting">
      <div class="setting-label">
        <label>{{i18n "admin.wizard.index"}}</label>
      </div>

      <div class="setting-value">
        <WizardMapper
          @inputs={{this.field.index}}
          @options={{this.fieldIndexOptions}}
        />
      </div>
    </div>

    {{#if this.isCategory}}
      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.field.property"}}</label>
        </div>

        <div class="setting-value">
          <ComboBox
            @value={{this.field.property}}
            @content={{this.categoryPropertyTypes}}
            @onChange={{this.updateFieldProperty}}
            @options={{hash none="admin.wizard.selector.placeholder.property"}}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.validations}}
      <WizardRealtimeValidations
        @field={{this.field}}
        @validations={{this.validations}}
      />
    {{/if}}
  </template>
}
