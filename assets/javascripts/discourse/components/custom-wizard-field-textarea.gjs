/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component, { Textarea } from "@ember/component";

export default class CustomWizardFieldTextarea extends Component {
  keyPress(e) {
    e.stopPropagation();
  }

  <template>
    <Textarea
      id={{this.field.id}}
      @value={{this.field.value}}
      tabindex={{this.field.tabindex}}
      class={{this.fieldClass}}
      placeholder={{this.field.translatedPlaceholder}}
    />
  </template>
}
