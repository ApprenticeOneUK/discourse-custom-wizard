/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import CustomWizardGroupSelector from "./custom-wizard-group-selector";

export default class CustomWizardFieldGroup extends Component {
  @action
  updateValue(value) {
    this.set("field.value", value);
  }

  <template>
    <CustomWizardGroupSelector
      @groups={{this.site.groups}}
      @class={{this.fieldClass}}
      @field={{this.field}}
      @whitelist={{this.field.content}}
      @value={{this.field.value}}
      @tabindex={{this.field.tabindex}}
      @onChange={{this.updateValue}}
      @options={{hash none="select_kit.default_header_text"}}
    />
  </template>
}
