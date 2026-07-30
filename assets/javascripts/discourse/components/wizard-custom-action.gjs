/* eslint-disable ember/no-classic-components, ember/no-mixins */
import Component, { Input } from "@ember/component";
import { fn, hash } from "@ember/helper";
import { action, computed } from "@ember/object";
import { classNameBindings } from "@ember-decorators/component";
import ComboBox from "discourse/select-kit/components/combo-box";
import DButton from "discourse/ui-kit/d-button";
import { i18n, i18n as i18n0 } from "discourse-i18n";
import { notificationLevels, selectKitContent } from "../lib/wizard";
import UndoChanges from "../mixins/undo-changes";
import WizardMapper from "./wizard-mapper";
import WizardMessage from "./wizard-message";
import WizardSubscriptionSelector from "./wizard-subscription-selector";
import WizardTextEditor from "./wizard-text-editor";

const WizardCustomActionBase = Component.extend(UndoChanges);

@classNameBindings(":wizard-custom-action", "visible")
export default class WizardCustomAction extends WizardCustomActionBase {
  componentType = "action";
  groupPropertyTypes = selectKitContent(["id", "name"]);
  availableNotificationLevels = notificationLevels.map((type) => {
    return {
      id: type,
      name: i18n(`admin.wizard.action.watch_x.notification_level.${type}`),
    };
  });
  messageUrl =
    "https://pavilion.tech/products/discourse-custom-wizard-plugin/documentation/action-settings";

  @computed("currentActionId", "action.id")
  get visible() {
    return this.action.id === this.currentActionId;
  }

  @computed("action.type")
  get createTopic() {
    return this.action.type === "create_topic";
  }

  @computed("action.type")
  get updateProfile() {
    return this.action.type === "update_profile";
  }

  @computed("action.type")
  get watchCategories() {
    return this.action.type === "watch_categories";
  }

  @computed("action.type")
  get watchTags() {
    return this.action.type === "watch_tags";
  }

  @computed("action.type")
  get sendMessage() {
    return this.action.type === "send_message";
  }

  @computed("action.type")
  get openComposer() {
    return this.action.type === "open_composer";
  }

  @computed("action.type")
  get sendToApi() {
    return this.action.type === "send_to_api";
  }

  @computed("action.type")
  get addToGroup() {
    return this.action.type === "add_to_group";
  }

  @computed("action.type")
  get routeTo() {
    return this.action.type === "route_to";
  }

  @computed("action.type")
  get createCategory() {
    return this.action.type === "create_category";
  }

  @computed("action.type")
  get createGroup() {
    return this.action.type === "create_group";
  }

  @computed("action.api")
  get apiEmpty() {
    return !this.action.api;
  }

  @computed(
    "basicTopicFields",
    "updateProfile",
    "createGroup",
    "createCategory"
  )
  get hasCustomFields() {
    return (
      this.basicTopicFields ||
      this.updateProfile ||
      this.createGroup ||
      this.createCategory
    );
  }

  @computed("createTopic", "sendMessage", "openComposer")
  get basicTopicFields() {
    return this.createTopic || this.sendMessage || this.openComposer;
  }

  @computed("createTopic", "openComposer")
  get publicTopicFields() {
    return this.createTopic || this.openComposer;
  }

  @computed("createTopic", "sendMessage")
  get showPostAdvanced() {
    return this.createTopic || this.sendMessage;
  }

  @computed("action.type")
  get messageKey() {
    return this.action.type ? "edit" : "type";
  }

  @computed("action.type")
  get customFieldsContext() {
    return `action.${this.action.type}`;
  }

  @computed("wizard.steps")
  get runAfterContent() {
    let content = this.wizard.steps.map(function (step) {
      return {
        id: step.id,
        name: step.title || step.id,
      };
    });

    content.unshift({
      id: "wizard_completion",
      name: i18n("admin.wizard.action.run_after.wizard_completion"),
    });

    return content;
  }

  @computed("apis")
  get availableApis() {
    return this.apis.map((a) => {
      return {
        id: a.name,
        name: a.title,
      };
    });
  }

  @computed("apis", "action.api")
  get availableEndpoints() {
    if (!this.action.api) {
      return [];
    }
    return this.apis.find((a) => a.name === this.action.api).endpoints;
  }

  @computed("fieldTypes")
  get hasEventField() {
    return this.fieldTypes.map((ft) => ft.id).includes("event");
  }

  @computed("fieldTypes")
  get hasLocationField() {
    return this.fieldTypes.map((ft) => ft.id).includes("location");
  }

  @action
  handleUndoChanges() {
    this.send("undoChanges");
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
  updateActionProperty(property, value) {
    this.set(`action.${property}`, value);
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
        <label>{{i18n0 "admin.wizard.type"}}</label>
      </div>

      <div class="setting-value">
        <WizardSubscriptionSelector
          @value={{this.action.type}}
          @feature="action"
          @attribute="type"
          @onChange={{this.handleChangeType}}
          @wizard={{this.wizard}}
          @options={{hash none="admin.wizard.select_type"}}
        />
      </div>
    </div>

    <div class="setting">
      <div class="setting-label">
        <label>{{i18n0 "admin.wizard.action.run_after.label"}}</label>
      </div>

      <div class="setting-value">
        <ComboBox
          @value={{this.action.run_after}}
          @content={{this.runAfterContent}}
          @onChange={{fn this.updateActionProperty "run_after"}}
        />
      </div>
    </div>

    <WizardMessage
      @key={{this.messageKey}}
      @url={{this.messageUrl}}
      @component="action"
    />

    {{#if this.basicTopicFields}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.title"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.title}}
            @property="title"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              wizardFieldSelection=true
              userFieldSelection="key,value"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.post"}}</label>
        </div>

        <div class="setting-value">
          <ComboBox
            @value={{this.action.post}}
            @content={{this.wizardFields}}
            @nameProperty="label"
            @onChange={{fn this.updateActionProperty "post"}}
            @options={{hash
              none="admin.wizard.selector.placeholder.wizard_field"
              isDisabled=this.showPostBuilder
            }}
          />

          <div class="setting-gutter">
            <Input @type="checkbox" @checked={{this.action.post_builder}} />
            <span>{{i18n0 "admin.wizard.action.post_builder.checkbox"}}</span>
          </div>
        </div>
      </div>

      {{#if this.action.post_builder}}
        <div class="setting full">
          <div class="setting-label">
            <label>{{i18n0 "admin.wizard.action.post_builder.label"}}</label>
          </div>

          <div class="setting-value editor">
            <WizardTextEditor
              @value={{this.action.post_template}}
              @wizardFields={{this.wizardFields}}
            />
          </div>
        </div>
      {{/if}}
    {{/if}}

    {{#if this.publicTopicFields}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.create_topic.category"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.category}}
            @property="category"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection="key,value"
              wizardFieldSelection=true
              userFieldSelection="key,value"
              categorySelection="output"
              wizardActionSelection="output"
              outputDefaultSelection="category"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.create_topic.tags"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.tags}}
            @property="tags"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              tagSelection="output"
              outputDefaultSelection="tag"
              listSelection="output"
              wizardFieldSelection=true
              userFieldSelection="key,value"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.create_topic.visible"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.visible}}
            @property="visible"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              wizardFieldSelection=true
              userFieldSelection=true
              context="action"
            }}
          />
        </div>
      </div>

      {{#if this.hasEventField}}
        <div class="setting full">
          <div class="setting-label">
            <label>{{i18n0
                "admin.wizard.action.create_topic.add_event"
              }}</label>
          </div>

          <div class="setting-value">
            <WizardMapper
              @inputs={{this.action.add_event}}
              @property="add_event"
              @onUpdate={{this.handleMappedFieldUpdated}}
              @options={{hash wizardFieldSelection=true context="action"}}
            />
          </div>
        </div>
      {{/if}}

      {{#if this.hasLocationField}}
        <div class="setting full">
          <div class="setting-label">
            <label>{{i18n0
                "admin.wizard.action.create_topic.add_location"
              }}</label>
          </div>

          <div class="setting-value">
            <WizardMapper
              @inputs={{this.action.add_location}}
              @property="add_location"
              @onUpdate={{this.handleMappedFieldUpdated}}
              @options={{hash wizardFieldSelection=true context="action"}}
            />
          </div>
        </div>
      {{/if}}
    {{/if}}

    {{#if this.sendMessage}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.send_message.recipient"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.recipient}}
            @property="recipient"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection="value,output"
              wizardFieldSelection=true
              userFieldSelection="key,value"
              groupSelection="key,value"
              userSelection="output"
              outputDefaultSelection="user"
              context="action"
              includeMessageableGroups="true"
            }}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.updateProfile}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.update_profile.setting"}}</label>
        </div>

        <WizardMapper
          @inputs={{this.action.profile_updates}}
          @property="profile_updates"
          @onUpdate={{this.handleMappedFieldUpdated}}
          @options={{hash
            inputTypes="association"
            textSelection="value"
            userFieldSelection="key"
            wizardFieldSelection="value"
            wizardActionSelection="value"
            keyDefaultSelection="userField"
            context="action"
          }}
        />
      </div>
    {{/if}}

    {{#if this.sendToApi}}
      <div class="setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.send_to_api.api"}}</label>
        </div>

        <div class="setting-value">
          <ComboBox
            @value={{this.action.api}}
            @content={{this.availableApis}}
            @onChange={{fn this.updateActionProperty "api"}}
            @options={{hash
              isDisabled=this.action.custom_title_enabled
              none="admin.wizard.action.send_to_api.select_an_api"
            }}
          />
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.send_to_api.endpoint"}}</label>
        </div>

        <div class="setting-value">
          <ComboBox
            @value={{this.action.api_endpoint}}
            @content={{this.availableEndpoints}}
            @onChange={{fn this.updateActionProperty "api_endpoint"}}
            @options={{hash
              isDisabled=this.apiEmpty
              none="admin.wizard.action.send_to_api.select_an_endpoint"
            }}
          />
        </div>
      </div>

      <div class="setting full">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.send_to_api.body"}}</label>
        </div>

        <div class="setting-value">
          <WizardTextEditor
            @value={{this.action.api_body}}
            @previewEnabled={{false}}
            @barEnabled={{false}}
            @wizardFields={{this.wizardFields}}
            @placeholder="admin.wizard.action.send_to_api.body_placeholder"
          />
        </div>
      </div>
    {{/if}}

    {{#if this.addToGroup}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.group"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.group}}
            @property="group"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection="value,output"
              wizardFieldSelection="key,value,assignment"
              userFieldSelection="key,value,assignment"
              wizardActionSelection=true
              groupSelection="value,output"
              outputDefaultSelection="group"
              context="action"
            }}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.routeTo}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.route_to.url"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.url}}
            @property="url"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              context="action"
              wizardFieldSelection=true
              userFieldSelection="key,value"
              groupSelection="key,value"
              categorySelection="key,value"
              userSelection="key,value"
            }}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.watchCategories}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.watch_categories.categories"
            }}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.categories}}
            @property="categories"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection="key,value"
              wizardFieldSelection=true
              wizardActionSelection=true
              userFieldSelection="key,value"
              categorySelection="output"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.watch_categories.mute_remainder"
            }}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.mute_remainder}}
            @property="mute_remainder"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              context="action"
              wizardFieldSelection=true
              userFieldSelection="key,value"
            }}
          />
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.watch_x.notification_level.label"
            }}</label>
        </div>

        <div class="setting-value">
          <ComboBox
            @value={{this.action.notification_level}}
            @content={{this.availableNotificationLevels}}
            @onChange={{fn this.updateActionProperty "notification_level"}}
            @options={{hash
              isDisabled=this.action.custom_title_enabled
              none="admin.wizard.action.watch_x.select_a_notification_level"
            }}
          />
        </div>
      </div>

      <div class="setting full">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.watch_x.wizard_user"}}</label>
        </div>

        <div class="setting-value">
          <Input @type="checkbox" @checked={{this.action.wizard_user}} />
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.watch_x.usernames"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.usernames}}
            @property="usernames"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              context="action"
              wizardFieldSelection=true
              userFieldSelection="key,value"
              userSelection="output"
            }}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.watchTags}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.watch_tags.tags"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.tags}}
            @property="tags"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection="key,value"
              tagSelection="output"
              wizardFieldSelection=true
              wizardActionSelection=true
              userFieldSelection="key,value"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.watch_x.notification_level.label"
            }}</label>
        </div>

        <div class="setting-value">
          <ComboBox
            @value={{this.action.notification_level}}
            @content={{this.availableNotificationLevels}}
            @onChange={{fn this.updateActionProperty "notification_level"}}
            @options={{hash
              isDisabled=this.action.custom_title_enabled
              none="admin.wizard.action.watch_x.select_a_notification_level"
            }}
          />
        </div>
      </div>

      <div class="setting full">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.watch_x.wizard_user"}}</label>
        </div>

        <div class="setting-value">
          <Input @type="checkbox" @checked={{this.action.wizard_user}} />
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.watch_x.usernames"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.usernames}}
            @property="usernames"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              context="action"
              wizardFieldSelection=true
              userFieldSelection="key,value"
              userSelection="output"
            }}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.createGroup}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.create_group.name"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.name}}
            @property="name"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection=true
              context="action"
            }}
          />
        </div>
      </div>
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.create_group.full_name"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.full_name}}
            @property="full_name"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection=true
              context="action"
            }}
          />
        </div>
      </div>
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.create_group.title"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.title}}
            @property="title"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection=true
              context="action"
            }}
          />
        </div>
      </div>
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.create_group.bio_raw"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.bio_raw}}
            @property="bio_raw"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection=true
              context="action"
            }}
          />
        </div>
      </div>
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.create_group.owner_usernames"
            }}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.owner_usernames}}
            @property="owner_usernames"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection=true
              userSelection="output"
              context="action"
            }}
          />
        </div>
      </div>
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.create_group.usernames"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.usernames}}
            @property="usernames"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection=true
              userSelection="output"
              context="action"
            }}
          />
        </div>
      </div>
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.create_group.grant_trust_level"
            }}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.grant_trust_level}}
            @property="grant_trust_level"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection=true
              context="action"
            }}
          />
        </div>
      </div>
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.create_group.mentionable_level"
            }}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.mentionable_level}}
            @property="mentionable_level"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection=true
              context="action"
            }}
          />
        </div>
      </div>
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.create_group.messageable_level"
            }}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.messageable_level}}
            @property="messageable_level"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection=true
              context="action"
            }}
          />
        </div>
      </div>
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.create_group.visibility_level"
            }}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.visibility_level}}
            @property="visibility_level"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection=true
              context="action"
            }}
          />
        </div>
      </div>
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.create_group.members_visibility_level"
            }}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.members_visibility_level}}
            @property="members_visibility_level"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection=true
              context="action"
            }}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.createCategory}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.create_category.name"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.name}}
            @property="name"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection="key,value,output"
              wizardFieldSelection=true
              userFieldSelection="key,value"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.create_category.slug"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.slug}}
            @property="slug"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection="key,value"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.create_category.color"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.color}}
            @property="color"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection="key,value"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.create_category.text_color"
            }}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.text_color}}
            @property="text_color"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection=true
              wizardFieldSelection=true
              userFieldSelection="key,value"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.create_category.parent_category"
            }}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.parent_category_id}}
            @property="parent_category_id"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection="key,value"
              wizardFieldSelection=true
              userFieldSelection="key,value"
              categorySelection="output"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.create_category.permissions"
            }}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.permissions}}
            @property="permissions"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              inputTypes="association"
              textSelection=true
              wizardFieldSelection=true
              wizardActionSelection="key"
              userFieldSelection=true
              groupSelection="key"
              context="action"
            }}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.hasCustomFields}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.custom_fields.label"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.custom_fields}}
            @property="custom_fields"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              inputTypes="association"
              customFieldSelection="key"
              wizardFieldSelection="value"
              wizardActionSelection="value"
              userFieldSelection="value"
              keyPlaceholder="admin.wizard.action.custom_fields.key"
              context=this.customFieldsContext
            }}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.sendMessage}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.required"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.required}}
            @property="required"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection="value"
              wizardFieldSelection=true
              userFieldSelection=true
              groupSelection=true
              context="action"
            }}
          />
        </div>
      </div>
    {{/if}}

    {{#if this.showPostAdvanced}}
      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.poster.label"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.poster}}
            @property="poster"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection="key,value"
              wizardFieldSelection=true
              userSelection="output"
              outputDefaultSelection="user"
              userLimit="1"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.guest_email.label"}}</label>
        </div>

        <div class="setting-value">
          <WizardMapper
            @inputs={{this.action.guest_email}}
            @property="guest_email"
            @onUpdate={{this.handleMappedFieldUpdated}}
            @options={{hash
              textSelection="key,value"
              wizardFieldSelection=true
              outputPlaceholder="admin.wizard.action.guest_email.placeholder"
              context="action"
            }}
          />
        </div>
      </div>

      <div class="setting full">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.skip_redirect.label"}}</label>
        </div>

        <div class="setting-value">
          <Input @type="checkbox" @checked={{this.action.skip_redirect}} />

          <span>
            {{i18n0
              "admin.wizard.action.skip_redirect.description"
              type="topic"
            }}
          </span>
        </div>
      </div>

      <div class="setting full">
        <div class="setting-label">
          <label>{{i18n0
              "admin.wizard.action.suppress_notifications.label"
            }}</label>
        </div>

        <div class="setting-value">
          <Input
            @type="checkbox"
            @checked={{this.action.suppress_notifications}}
          />

          <span>
            {{i18n0
              "admin.wizard.action.suppress_notifications.description"
              type="topic"
            }}
          </span>
        </div>
      </div>
    {{/if}}

    {{#if this.routeTo}}
      <div class="setting">
        <div class="setting-label">
          <label>{{i18n0 "admin.wizard.action.route_to.code"}}</label>
        </div>

        <div class="setting-value">
          <Input @value={{this.action.code}} />
        </div>
      </div>
    {{/if}}
  </template>
}
