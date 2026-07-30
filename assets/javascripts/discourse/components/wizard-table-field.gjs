/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { on } from "@ember/modifier";
import { action, computed } from "@ember/object";
import { LinkTo } from "@ember/routing";
import { classNameBindings } from "@ember-decorators/component";
import rawDate from "discourse/helpers/raw-date";
import dAvatar from "discourse/ui-kit/helpers/d-avatar";
import dDiscourseTag from "discourse/ui-kit/helpers/d-discourse-tag";
import dFormatDate from "discourse/ui-kit/helpers/d-format-date";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n, i18n as i18n0 } from "discourse-i18n";

@classNameBindings("value.type")
export default class WizardTableField extends Component {
  textState = "text-collapsed";
  toggleText = i18n("admin.wizard.expand_text");

  @computed("value.type")
  get isText() {
    return this.value.type === "text";
  }

  @computed("value.type")
  get isComposer() {
    return this.value.type === "composer";
  }

  @computed("value.type")
  get isDate() {
    return this.value.type === "date";
  }

  @computed("value.type")
  get isTime() {
    return this.value.type === "time";
  }

  @computed("value.type")
  get isDateTime() {
    return this.value.type === "date_time";
  }

  @computed("value.type")
  get isNumber() {
    return this.value.type === "number";
  }

  @computed("value.type")
  get isCheckbox() {
    return this.value.type === "checkbox";
  }

  @computed("value.type")
  get isUrl() {
    return this.value.type === "url";
  }

  @computed("value.type")
  get isUpload() {
    return this.value.type === "upload";
  }

  @computed("value.type")
  get isDropdown() {
    return this.value.type === "dropdown";
  }

  @computed("value.type")
  get isTag() {
    return this.value.type === "tag";
  }

  @computed("value.type")
  get isCategory() {
    return this.value.type === "category";
  }

  @computed("value.type")
  get isTopic() {
    return this.value.type === "topic";
  }

  @computed("value.type")
  get isGroup() {
    return this.value.type === "group";
  }

  @computed("value.type")
  get isUserSelector() {
    return this.value.type === "user_selector";
  }

  @computed("field")
  get isSubmittedAt() {
    return this.field === "submitted_at";
  }

  @computed("value.type")
  get isComposerPreview() {
    return this.value.type === "composer_preview";
  }

  @computed("value", "isUser", "isSubmittedAt")
  get hasValue() {
    if (this.isUser || this.isSubmittedAt) {
      return this.value;
    }
    return this.value && this.value.value;
  }

  @computed("field", "value.type")
  get isUser() {
    return (
      this.field === "username" ||
      this.field === "user" ||
      this.value.type === "user"
    );
  }

  @computed("value.type")
  get isLongtext() {
    return ["textarea", "long_text"].includes(this.value.type);
  }

  @computed("value")
  get checkboxValue() {
    if (this.isCheckbox) {
      return (
        this.value.value === true ||
        (Array.isArray(this.value.value) && this.value.value.includes("true"))
      );
    }
  }

  @action
  expandText(event) {
    event.preventDefault();

    const state = this.get("textState");

    if (state === "text-collapsed") {
      this.set("textState", "text-expanded");
      this.set("toggleText", i18n("admin.wizard.collapse_text"));
    } else if (state === "text-expanded") {
      this.set("textState", "text-collapsed");
      this.set("toggleText", i18n("admin.wizard.expand_text"));
    }
  }

  @computed("value")
  get file() {
    if (this.isUpload) {
      return this.value.value;
    }
  }

  @computed("value")
  get submittedUsers() {
    const users = [];

    if (this.isUserSelector) {
      const userData = this.value.value;
      const usernames = [];

      if (userData.indexOf(",")) {
        usernames.push(...userData.split(","));

        usernames.forEach((u) => {
          const user = {
            username: u,
            url: `/u/${u}`,
          };
          users.push(user);
        });
      }
    }
    return users;
  }

  @computed("isUser", "field", "value")
  get username() {
    if (this.isUser) {
      return this.value.username;
    }
    if (this.field === "username") {
      return this.value.value;
    }
    return null;
  }

  @computed("username")
  get showUsername() {
    return Boolean(this.username);
  }

  @computed("username")
  get userProfileUrl() {
    if (this.username) {
      return `/u/${this.username}`;
    }
    return "/";
  }

  @computed("value")
  get categoryUrl() {
    if (this.isCategory) {
      return `/c/${this.value.value}`;
    }
  }

  @computed("value")
  get groupUrl() {
    if (this.isGroup) {
      return `/g/${this.value.value}`;
    }
  }

  <template>
    {{#if this.hasValue}}
      {{#if this.isText}}
        {{this.value.value}}
      {{/if}}

      {{#if this.isLongtext}}
        <div class="wizard-table-long-text">
          <p class="wizard-table-long-text-content {{this.textState}}">
            {{this.value.value}}
          </p>
          <a href {{on "click" this.expandText}}>
            {{this.toggleText}}
          </a>
        </div>
      {{/if}}

      {{#if this.isComposer}}
        <div class="wizard-table-long-text">
          <p
            class="wizard-table-composer-text wizard-table-long-text-content
              {{this.textState}}"
          >
            {{this.value.value}}
          </p>
          <a href {{on "click" this.expandText}}>
            {{this.toggleText}}
          </a>
        </div>
      {{/if}}

      {{#if this.isComposerPreview}}
        {{dIcon "message"}}
        <span class="wizard-table-composer-text">
          {{i18n0 "admin.wizard.submissions.composer_preview"}}:
          {{this.value.value}}
        </span>
      {{/if}}

      {{#if this.isTextOnly}}
        {{this.value.value}}
      {{/if}}

      {{#if this.isDate}}
        <span class="wizard-table-icon-item">
          {{dIcon "calendar"}}{{this.value.value}}
        </span>
      {{/if}}

      {{#if this.isTime}}
        <span class="wizard-table-icon-item">
          {{dIcon "clock"}}{{this.value.value}}
        </span>
      {{/if}}

      {{#if this.isDateTime}}
        <span class="wizard-table-icon-item" title={{this.value.value}}>
          {{dIcon "calendar"}}{{dFormatDate this.value.value format="medium"}}
        </span>
      {{/if}}

      {{#if this.isNumber}}
        {{this.value.value}}
      {{/if}}

      {{#if this.isCheckbox}}
        {{#if this.checkboxValue}}
          <span class="wizard-table-icon-item checkbox-true">
            {{dIcon "check"}}{{this.value.value}}
          </span>
        {{else}}
          <span class="wizard-table-icon-item checkbox-false">
            {{dIcon "xmark"}}{{this.value.value}}
          </span>
        {{/if}}
      {{/if}}

      {{#if this.isUrl}}
        <span class="wizard-table-icon-item url">
          {{dIcon "link"}}
          <a
            target="_blank"
            rel="noopener noreferrer"
            href={{this.value.value}}
          >
            {{this.value.value}}
          </a>
        </span>
      {{/if}}

      {{#if this.isUpload}}
        <a
          target="_blank"
          rel="noopener noreferrer"
          class="attachment"
          href={{this.file.url}}
          download
        >
          {{this.file.original_filename}}
        </a>
      {{/if}}

      {{#if this.isDropdown}}
        <span class="wizard-table-icon-item">
          {{dIcon "check-square"}}
          {{this.value.value}}
        </span>
      {{/if}}

      {{#if this.isTag}}
        {{#each this.value.value as |tag|}}
          {{dDiscourseTag tag}}
        {{/each}}
      {{/if}}

      {{#if this.isCategory}}
        <strong>
          {{i18n0 "admin.wizard.submissions.category_id"}}:
        </strong>
        <a
          target="_blank"
          rel="noopener noreferrer"
          href={{this.categoryUrl}}
          title={{this.value.value}}
        >
          {{this.value.value}}
        </a>
      {{/if}}

      {{#if this.isTopic}}
        <strong>
          {{i18n0 "admin.wizard.submissions.topic_id"}}:
        </strong>
        {{#each this.value.value as |topic|}}
          <a
            target="_blank"
            rel="noopener noreferrer"
            href={{topic.url}}
            title={{topic.fancy_title}}
          >
            {{topic.id}}
          </a>
        {{/each}}
      {{/if}}

      {{#if this.isGroup}}
        <strong>
          {{i18n0 "admin.wizard.submissions.group_id"}}:
        </strong>
        {{this.value.value}}
      {{/if}}

      {{#if this.isUserSelector}}
        {{#each this.submittedUsers as |user|}}
          {{dIcon "user"}}
          <a
            target="_blank"
            rel="noopener noreferrer"
            href={{user.url}}
            title={{user.username}}
          >
            {{user.username}}
          </a>
        {{/each}}
      {{/if}}

      {{#if this.isUser}}
        <LinkTo @route="user" @model={{this.value.username}}>
          {{dAvatar this.value imageSize="tiny"}}
        </LinkTo>
      {{/if}}

      {{#if this.showUsername}}
        <a
          target="_blank"
          rel="noopener noreferrer"
          href={{this.userProfileUrl}}
          title={{this.username}}
        >
          {{this.username}}
        </a>
      {{/if}}

      {{#if this.isSubmittedAt}}
        <span class="date" title={{this.value}}>
          {{rawDate this.value}}
        </span>
      {{/if}}
    {{else}}
      &mdash;
    {{/if}}
  </template>
}
