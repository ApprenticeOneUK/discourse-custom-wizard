/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import ComboBox from "discourse/select-kit/components/combo-box";

export default class CustomWizardFieldDropdown extends Component {
  keyPress(e) {
    e.stopPropagation();
  }

  @action
  onChangeValue(value) {
    this.set("field.value", value);
  }

  <template>
    <ComboBox
      @class={{this.fieldClass}}
      @value={{this.field.value}}
      @content={{this.field.content}}
      @tabindex={{this.field.tabindex}}
      @onChange={{this.onChangeValue}}
      @options={{hash none="select_kit.default_header_text"}}
    />
  </template>
}
