/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component, { Input } from "@ember/component";

export default class CustomWizardFieldText extends Component {
  keyPress(e) {
    e.stopPropagation();
  }

  <template>
    <Input
      id={{this.field.id}}
      @value={{this.field.value}}
      tabindex={{this.field.tabindex}}
      class={{this.fieldClass}}
      placeholder={{this.field.translatedPlaceholder}}
      autocomplete={{this.autocomplete}}
    />
  </template>
}
