/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import CustomWizardTopicSelector from "./custom-wizard-topic-selector";

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

  <template>
    <CustomWizardTopicSelector
      @topics={{this.topics}}
      @category={{this.field.category}}
      @onChangeCallback={{this.setValue}}
      @options={{hash maximum=this.field.limit}}
    />
  </template>
}
