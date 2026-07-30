/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { hash } from "@ember/helper";
import CustomWizardTagChooser from "./custom-wizard-tag-chooser";

export default class CustomWizardFieldTag extends Component {
  <template>
    <CustomWizardTagChooser
      @tags={{this.field.value}}
      @class={{this.fieldClass}}
      @tabindex={{this.field.tabindex}}
      @tagGroups={{this.field.tag_groups}}
      @whitelist={{this.field.content}}
      @everyTag={{true}}
      @options={{hash
        maximum=this.field.limit
        allowAny=this.field.can_create_tag
      }}
    />
  </template>
}
