/* eslint-disable ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
import Component, { Input } from "@ember/component";
import { hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action, computed } from "@ember/object";
import { alias, equal, gt, or } from "@ember/object/computed";
import { getOwner } from "@ember/owner";
import { later } from "@ember/runloop";
import { service } from "@ember/service";
import ComboBox from "discourse/select-kit/components/combo-box";
import MultiSelect from "discourse/select-kit/components/multi-select";
import TagChooser from "discourse/select-kit/components/tag-chooser";
import { i18n, i18n as i18n0 } from "discourse-i18n";
import {
  generateName,
  sentenceCase,
  snakeCase,
  tagNames,
  userProperties,
} from "../lib/wizard";
import { defaultSelectionType, selectionTypes } from "../lib/wizard-mapper";
import WizardMapperSelectorType from "./wizard-mapper-selector-type";
import WizardUserChooser from "./wizard-user-chooser";
import WizardValueList from "./wizard-value-list";

const customFieldActionMap = {
  topic: ["create_topic", "send_message"],
  post: ["create_topic", "send_message"],
  category: ["create_category"],
  group: ["create_group"],
  user: ["update_profile"],
};

const values = ["present", "true", "false"];

const WizardMapperSelector = Component.extend({
  classNameBindings: [":mapper-selector", "activeType"],
  subscription: service(),

  showText: computed("activeType", function () {
    return this.showInput("text");
  }),
  showWizardField: computed("activeType", function () {
    return this.showInput("wizardField");
  }),
  showWizardAction: computed("activeType", function () {
    return this.showInput("wizardAction");
  }),
  showUserField: computed("activeType", function () {
    return this.showInput("userField");
  }),
  showUserFieldOptions: computed("activeType", function () {
    return this.showInput("userFieldOptions");
  }),
  showCategory: computed("activeType", function () {
    return this.showInput("category");
  }),
  showTag: computed("activeType", function () {
    return this.showInput("tag");
  }),
  showGroup: computed("activeType", function () {
    return this.showInput("group");
  }),
  showUser: computed("activeType", function () {
    return this.showInput("user");
  }),
  showList: computed("activeType", function () {
    return this.showInput("list");
  }),
  showCustomField: computed("activeType", function () {
    return this.showInput("customField");
  }),
  showValue: computed("activeType", function () {
    return this.showInput("value");
  }),
  textEnabled: computed("options.textSelection", "inputType", function () {
    return this.optionEnabled("textSelection");
  }),
  wizardFieldEnabled: computed(
    "options.wizardFieldSelection",
    "inputType",
    function () {
      return this.optionEnabled("wizardFieldSelection");
    }
  ),
  wizardActionEnabled: computed(
    "options.wizardActionSelection",
    "inputType",
    function () {
      return this.optionEnabled("wizardActionSelection");
    }
  ),
  customFieldEnabled: computed(
    "options.customFieldSelection",
    "inputType",
    function () {
      return this.optionEnabled("customFieldSelection");
    }
  ),
  userFieldEnabled: computed(
    "options.userFieldSelection",
    "inputType",
    function () {
      return this.optionEnabled("userFieldSelection");
    }
  ),
  userFieldOptionsEnabled: computed(
    "options.userFieldOptionsSelection",
    "inputType",
    function () {
      return this.optionEnabled("userFieldOptionsSelection");
    }
  ),
  categoryEnabled: computed(
    "options.categorySelection",
    "inputType",
    function () {
      return this.optionEnabled("categorySelection");
    }
  ),
  tagEnabled: computed("options.tagSelection", "inputType", function () {
    return this.optionEnabled("tagSelection");
  }),
  groupEnabled: computed("options.groupSelection", "inputType", function () {
    return this.optionEnabled("groupSelection");
  }),
  guestGroup: computed("options.guestGroup", "inputType", function () {
    return this.optionEnabled("guestGroup");
  }),
  includeMessageableGroups: computed(
    "options.includeMessageableGroups",
    "inputType",
    function () {
      return this.optionEnabled("includeMessageableGroups");
    }
  ),
  userEnabled: computed("options.userSelection", "inputType", function () {
    return this.optionEnabled("userSelection");
  }),
  listEnabled: computed("options.listSelection", "inputType", function () {
    return this.optionEnabled("listSelection");
  }),
  valueEnabled: equal("connector", "is"),

  groups: computed(
    "site.groups",
    "guestGroup",
    "subscription.subscriptionType",
    function () {
      let result = this.site.groups;
      if (!this.guestGroup) {
        return result;
      }

      if (
        ["standard", "business"].includes(this.subscription.subscriptionType)
      ) {
        let guestIndex;
        result.forEach((r, index) => {
          if (r.id === 0) {
            r.name = i18n("admin.wizard.selector.label.users");
            guestIndex = index;
          }
        });
        result.splice(guestIndex, 0, {
          id: -1,
          name: i18n("admin.wizard.selector.label.guests"),
        });
      }

      return result;
    }
  ),
  categories: alias("site.categories"),
  showComboBox: or(
    "showWizardField",
    "showWizardAction",
    "showUserField",
    "showUserFieldOptions",
    "showCustomField",
    "showValue"
  ),
  showMultiSelect: or("showCategory", "showGroup"),
  hasTypes: gt("selectorTypes.length", 1),
  showTypes: false,

  didInsertElement() {
    this._super(...arguments);
    if (
      !this.activeType ||
      (this.activeType && !this[`${this.activeType}Enabled`])
    ) {
      later(() => this.resetActiveType());
    }

    this._documentClickHandler = this.documentClick.bind(this);
    document.addEventListener("click", this._documentClickHandler);
  },

  didReceiveAttrs() {
    this._super(...arguments);

    if (this._receivedInputType && this._inputType !== this.inputType) {
      this.resetActiveType();
    }

    this._inputType = this.inputType;
    this._receivedInputType = true;
  },

  willDestroyElement() {
    this._super(...arguments);
    document.removeEventListener("click", this._documentClickHandler);
  },

  documentClick(e) {
    if (this._state === "destroying") {
      return;
    }
    if (!e.target.closest(".type-selector") && this.showTypes) {
      this.set("showTypes", false);
    }
  },

  selectorTypes: computed("connector", function () {
    return selectionTypes
      .filter((type) => this[`${type}Enabled`])
      .map((type) => ({ type, label: this.typeLabel(type) }));
  }),

  activeTypeLabel: computed("activeType", function () {
    return this.typeLabel(this.activeType);
  }),

  typeLabel(type) {
    return type ? i18n(`admin.wizard.selector.label.${snakeCase(type)}`) : null;
  },

  comboBoxAllowAny: or("showWizardField", "showWizardAction"),

  showController: computed(function () {
    return getOwner(this).lookup("controller:admin-wizards-wizard-show");
  }),

  comboBoxContent: computed(
    "activeType",
    "showController.wizardFields.[]",
    "showController.wizard.actions.[]",
    "showController.userFields.[]",
    "showController.currentField.id",
    "showController.currentAction.id",
    "showController.customFields",
    function () {
      const activeType = this.activeType;
      const wizardFields = this.showController.wizardFields;
      const wizardActions = this.showController.wizard.actions;
      const userFields = this.showController.userFields;
      const currentFieldId = this.showController.currentField?.id;
      const currentActionId = this.showController.currentAction?.id;
      const customFields = this.showController.customFields;
      let content;
      let context;
      let contextType;

      if (this.options.context) {
        let contextAttrs = this.options.context.split(".");
        context = contextAttrs[0];
        contextType = contextAttrs[1];
      }

      if (activeType === "wizardField") {
        content = wizardFields.map((f) => ({
          id: f.id,
          name: f.label,
          type: f.type,
        }));

        if (context === "field") {
          content = content.filter((field) => field.id !== currentFieldId);
        }
      }

      if (activeType === "wizardAction") {
        content = wizardActions.map((a) => ({
          id: a.id,
          name: `${generateName(a.type)} (${a.id})`,
          type: a.type,
        }));

        if (context === "action") {
          content = content.filter((a) => a.id !== currentActionId);
        }
      }

      if (activeType === "userField") {
        content = userProperties
          .map((f) => ({
            id: f,
            name: generateName(f),
          }))
          .concat(userFields || []);

        if (
          context === "action" &&
          this.inputType === "association" &&
          this.selectorType === "key"
        ) {
          const excludedFields = ["username", "email", "trust_level"];
          content = content.filter(
            (userField) => excludedFields.indexOf(userField.id) === -1
          );
        }
      }

      if (activeType === "userFieldOptions") {
        content = userFields;
      }

      if (activeType === "customField") {
        content = customFields
          .filter((f) => {
            return (
              f.type !== "json" &&
              customFieldActionMap[f.klass].includes(contextType)
            );
          })
          .map((f) => ({
            id: f.name,
            name: `${sentenceCase(f.klass)} ${f.name} (${f.type})`,
          }));
      }

      if (activeType === "value") {
        content = values.map((value) => ({
          id: value,
          name: value,
        }));
      }

      return content;
    }
  ),

  multiSelectContent: computed("activeType", function () {
    return {
      category: this.categories,
      group: this.groups,
      list: "",
    }[this.activeType];
  }),

  placeholderKey: computed("activeType", "inputType", function () {
    if (
      this.activeType === "text" &&
      this.options[`${this.selectorType}Placeholder`]
    ) {
      return this.options[`${this.selectorType}Placeholder`];
    } else {
      return `admin.wizard.selector.placeholder.${snakeCase(this.activeType)}`;
    }
  }),

  multiSelectOptions: computed("activeType", function () {
    let result = {
      none: this.placeholderKey,
    };

    if (this.activeType === "list") {
      result.allowAny = true;
    }

    return result;
  }),

  userOptions: computed(
    "includeMessageableGroups",
    "options.userLimit",
    function () {
      const opts = {
        includeMessageableGroups: this.includeMessageableGroups,
      };
      if (this.options.userLimit) {
        opts.maximum = this.options.userLimit;
      }
      return opts;
    }
  ),

  optionEnabled(type) {
    const options = this.options;
    if (!options) {
      return false;
    }

    const option = options[type];
    if (option === true) {
      return true;
    }
    if (typeof option !== "string") {
      return false;
    }

    return option.split(",").filter((o) => {
      return [this.selectorType, this.inputType].indexOf(o) !== -1;
    }).length;
  },

  showInput(type) {
    return this.activeType === type && this[`${type}Enabled`];
  },

  changeValue(value) {
    this.set("value", value);
    this.onUpdate("selector", this.activeType);
  },

  resetActiveType() {
    this.set(
      "activeType",
      defaultSelectionType(this.selectorType, this.options, this.connector)
    );
  },
});

export default class WizardMapperSelectorComponent extends WizardMapperSelector {
  @action
  toggleType(type) {
    this.set("activeType", type);
    this.set("showTypes", false);
    this.set("value", null);
    this.onUpdate("selector");
  }

  @action
  toggleTypes() {
    this.toggleProperty("showTypes");
  }

  @action
  updateValue(value) {
    this.changeValue(value);
  }

  @action
  updateTagValue(items) {
    this.changeValue(tagNames(items));
  }

  @action
  changeInputValue(event) {
    this.changeValue(event.target.value);
  }

  <template>
    <div class="type-selector">
      {{#if this.hasTypes}}
        <a role="button" {{on "click" this.toggleTypes}} class="active">
          {{this.activeTypeLabel}}
        </a>

        {{#if this.showTypes}}
          <div class="selector-types">
            {{#each this.selectorTypes as |item|}}
              <WizardMapperSelectorType
                @activeType={{this.activeType}}
                @item={{item}}
                @toggle={{this.toggleType}}
              />
            {{/each}}
          </div>
        {{/if}}
      {{else}}
        <span>{{this.activeTypeLabel}}</span>
      {{/if}}
    </div>

    <div class="input">
      {{#if this.showText}}
        <Input
          @type="text"
          @value={{this.value}}
          placeholder={{i18n0 this.placeholderKey}}
          {{on "change" this.changeInputValue}}
        />
      {{/if}}

      {{#if this.showComboBox}}
        <ComboBox
          @value={{this.value}}
          @content={{this.comboBoxContent}}
          @onChange={{this.updateValue}}
          @options={{hash
            none=this.placeholderKey
            allowAny=this.comboBoxAllowAny
          }}
        />
      {{/if}}

      {{#if this.showMultiSelect}}
        <MultiSelect
          @content={{this.multiSelectContent}}
          @value={{this.value}}
          @onChange={{this.updateValue}}
          @options={{this.multiSelectOptions}}
        />
      {{/if}}

      {{#if this.showList}}
        <WizardValueList
          @values={{this.value}}
          @addKey={{this.placeholderKey}}
          @onChange={{this.updateValue}}
        />
      {{/if}}

      {{#if this.showTag}}
        <TagChooser
          @tags={{this.value}}
          @onChange={{this.updateTagValue}}
          @everyTag={{true}}
          @options={{hash none=this.placeholderKey filterable=true}}
        />
      {{/if}}

      {{#if this.showUser}}
        <WizardUserChooser
          @placeholderKey={{this.placeholderKey}}
          @value={{this.value}}
          @autocomplete="discourse"
          @onChange={{this.updateValue}}
          @options={{this.userOptions}}
        />
      {{/if}}
    </div>
  </template>
}
