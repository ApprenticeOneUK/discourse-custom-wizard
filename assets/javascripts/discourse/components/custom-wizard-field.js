/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { computed } from "@ember/object";
import { dasherize } from "@ember/string";
import { classNameBindings } from "@ember-decorators/component";
import { cook } from "discourse/lib/text";

@classNameBindings(":wizard-field", "typeClasses", "field.invalid", "field.id")
export default class CustomWizardField extends Component {
  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);

    cook(this.field.translatedDescription).then((cookedDescription) => {
      this.set("cookedDescription", cookedDescription);
    });
  }

  @computed("field.type", "field.id")
  get typeClasses() {
    const type = dasherize(this.field.type);
    return `${type}-field ${type}-${dasherize(this.field.id)}`;
  }

  @computed("field.id")
  get fieldClass() {
    return `field-${dasherize(this.field.id)} wizard-focusable`;
  }

  @computed("field.type", "field.id")
  get inputComponentName() {
    if (this.field.type === "text_only") {
      return false;
    }
    return dasherize(
      this.field.type === "component"
        ? this.field.id
        : `custom-wizard-field-${this.field.type}`
    );
  }

  @computed("field.type")
  get textType() {
    return ["text", "textarea"].includes(this.field.type);
  }
}
