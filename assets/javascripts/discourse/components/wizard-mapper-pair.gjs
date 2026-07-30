/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { computed } from "@ember/object";
import { classNameBindings } from "@ember-decorators/component";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { connectorContent } from "../lib/wizard-mapper";
import WizardMapperConnector from "./wizard-mapper-connector";
import WizardMapperSelector from "./wizard-mapper-selector";

@classNameBindings(":mapper-pair", "hasConnector::no-connector")
export default class WizardMapperPair extends Component {
  @computed("pair.index")
  get firstPair() {
    return this.pair.index > 0;
  }

  @computed("firstPair")
  get showRemove() {
    return this.firstPair;
  }

  @computed("pair.index", "pair.pairCount")
  get showJoin() {
    return this.pair.index < this.pair.pairCount - 1;
  }

  @computed("inputType", "options")
  get connectors() {
    return connectorContent("pair", this.inputType, this.options);
  }

  <template>
    <div class="key mapper-block">
      <WizardMapperSelector
        @selectorType="key"
        @inputType={{this.inputType}}
        @value={{this.pair.key}}
        @activeType={{this.pair.key_type}}
        @options={{this.options}}
        @onUpdate={{this.onUpdate}}
      />
    </div>

    <WizardMapperConnector
      @connector={{this.pair.connector}}
      @connectors={{this.connectors}}
      @connectorType="pair"
      @inputType={{this.inputType}}
      @options={{this.options}}
      @onUpdate={{this.onUpdate}}
    />

    <div class="value mapper-block">
      <WizardMapperSelector
        @selectorType="value"
        @inputType={{this.inputType}}
        @value={{this.pair.value}}
        @activeType={{this.pair.value_type}}
        @options={{this.options}}
        @onUpdate={{this.onUpdate}}
        @connector={{this.pair.connector}}
      />
    </div>

    {{#if this.showJoin}}
      <span class="join-pair">&</span>
    {{/if}}

    {{#if this.showRemove}}
      <a
        role="button"
        {{on "click" (fn this.removePair this.pair)}}
        class="remove-pair"
      >{{dIcon "xmark"}}</a>
    {{/if}}
  </template>
}
