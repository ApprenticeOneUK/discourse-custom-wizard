/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action } from "@ember/object";

export default class CustomWizardFieldTopic extends Component {
  topics = [];

  didInsertElement() {
    super.didInsertElement(...arguments);
    const value = this.field.value;

    if (value) {
      this.set("topics", value);
    }
  }

  @action
  setValue(_, topics) {
    if (topics.length) {
      this.set("field.value", topics);
    }
  }
}
