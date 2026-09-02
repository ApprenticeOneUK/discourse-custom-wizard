/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { hash } from "@ember/helper";
import { action, computed } from "@ember/object";
import { i18n } from "discourse-i18n";
import CustomWizardDropdown from "./custom-wizard-dropdown";

function textFromHTML(value) {
  const template = document.createElement("template");
  template.innerHTML = value || "";
  return template.content.textContent.trim();
}

export default class CustomWizardFieldDropdown extends Component {
  keyPress(e) {
    e.stopPropagation();
  }

  @action
  onChangeValue(value) {
    this.set("field.value", value);
  }

  @computed("field.translatedLabel")
  get filterAriaLabel() {
    return i18n("wizard.dropdown_filter_label", {
      label: textFromHTML(this.field.translatedLabel),
    });
  }

  <template>
    <CustomWizardDropdown
      @class={{this.fieldClass}}
      @value={{this.field.value}}
      @content={{this.field.content}}
      @tabindex={{this.field.tabindex}}
      @onChange={{this.onChangeValue}}
      @options={{hash
        none="select_kit.default_header_text"
        headerAriaLabelledby=this.fieldLabelId
        filterAriaLabel=this.filterAriaLabel
      }}
    />
  </template>
}
