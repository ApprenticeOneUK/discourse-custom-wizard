/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { computed } from "@ember/object";
import { classNameBindings, tagName } from "@ember-decorators/component";

@tagName("a")
@classNameBindings("active")
export default class WizardMapperSelectorType extends Component {
  @computed("item.type", "activeType")
  get active() {
    return this.item.type === this.activeType;
  }

  click() {
    this.toggle(this.item.type);
  }

  <template>{{this.item.label}}</template>
}
