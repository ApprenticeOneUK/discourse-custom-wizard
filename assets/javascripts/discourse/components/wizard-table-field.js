/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action, computed } from "@ember/object";
import { classNameBindings } from "@ember-decorators/component";
import { i18n } from "discourse-i18n";

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
  expandText() {
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
}
