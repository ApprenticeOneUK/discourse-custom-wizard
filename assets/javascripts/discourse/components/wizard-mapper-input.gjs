/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action, computed, set } from "@ember/object";
import { trackedArray } from "@ember/reactive/collections";
import { classNameBindings } from "@ember-decorators/component";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import {
  connectorContent,
  defaultConnector,
  defaultSelectionType,
  inputTypesContent,
  newPair,
} from "../lib/wizard-mapper";
import WizardMapperConnector from "./wizard-mapper-connector";
import WizardMapperPair from "./wizard-mapper-pair";
import WizardMapperSelector from "./wizard-mapper-selector";

@classNameBindings(":mapper-input", "inputType")
export default class WizardMapperInput extends Component {
  @computed("input.type")
  get inputType() {
    return this.input.type;
  }

  @computed("inputType")
  get isConditional() {
    return this.inputType === "conditional";
  }

  @computed("inputType")
  get isAssignment() {
    return this.inputType === "assignment";
  }

  @computed("inputType")
  get isAssociation() {
    return this.inputType === "association";
  }

  @computed("inputType")
  get isValidation() {
    return this.inputType === "validation";
  }

  @computed("isConditional", "isAssignment")
  get hasOutput() {
    return this.isConditional || this.isAssignment;
  }

  @computed("isConditional", "isAssociation", "isValidation")
  get hasPairs() {
    return this.isConditional || this.isAssociation || this.isValidation;
  }

  @computed("isAssignment")
  get canAddPair() {
    return !this.isAssignment;
  }

  @computed("input.type", "options")
  get connectors() {
    return connectorContent("output", this.input.type, this.options);
  }

  @computed("options")
  get inputTypes() {
    return inputTypesContent(this.options);
  }

  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);

    if (this._inputType !== this.input.type) {
      this._inputType = this.input.type;
      this.setupType();
    }
  }

  setupType() {
    if (this.hasPairs && (!this.input.pairs || this.input.pairs.length < 1)) {
      this.addPair();
    }

    if (this.hasOutput) {
      this.set("input.output", null);

      if (!this.input.outputConnector) {
        const options = this.options;
        this.set("input.output_type", defaultSelectionType("output", options));
        this.set(
          "input.output_connector",
          defaultConnector("output", this.inputType, options)
        );
      }
    }
  }

  @action
  addPair() {
    if (!this.input.pairs) {
      this.set("input.pairs", trackedArray());
    }

    const pairs = this.input.pairs;
    const pairCount = pairs.length + 1;

    pairs.forEach((pair) => set(pair, "pairCount", pairCount));

    pairs.push(
      newPair(
        this.input.type,
        Object.assign({}, this.options, { index: pairs.length, pairCount })
      )
    );
  }

  @action
  removePair(pair) {
    const pairs = this.input.pairs;
    const pairCount = pairs.length - 1;

    pairs.forEach((item) => set(item, "pairCount", pairCount));
    const index = pairs.indexOf(pair);
    if (index !== -1) {
      pairs.splice(index, 1);
    }
  }

  <template>
    <WizardMapperConnector
      @connector={{this.input.type}}
      @connectors={{this.inputTypes}}
      @inputTypes={{true}}
      @inputType={{this.inputType}}
      @connectorType="type"
      @options={{this.options}}
      @onUpdate={{this.onUpdate}}
    />

    {{#if this.hasPairs}}
      <div class="mapper-pairs mapper-block">
        {{#each this.input.pairs as |pair|}}
          <WizardMapperPair
            @pair={{pair}}
            @last={{pair.last}}
            @inputType={{this.inputType}}
            @options={{this.options}}
            @removePair={{this.removePair}}
            @onUpdate={{this.onUpdate}}
          />
        {{/each}}

        {{#if this.canAddPair}}
          <a role="button" {{on "click" this.addPair}} class="add-pair">
            {{dIcon "plus"}}
          </a>
        {{/if}}
      </div>
    {{/if}}

    {{#if this.hasOutput}}
      {{#if this.hasPairs}}
        <WizardMapperConnector
          @connector={{this.input.output_connector}}
          @connectors={{this.connectors}}
          @connectorType="output"
          @inputType={{this.inputType}}
          @options={{this.options}}
          @onUpdate={{this.onUpdate}}
        />
      {{/if}}

      <div class="output mapper-block">
        <WizardMapperSelector
          @selectorType="output"
          @inputType={{this.input.type}}
          @value={{this.input.output}}
          @activeType={{this.input.output_type}}
          @options={{this.options}}
          @onUpdate={{this.onUpdate}}
        />
      </div>
    {{/if}}

    <a
      role="button"
      class="remove-input"
      {{on "click" (fn this.remove this.input)}}
    >
      {{dIcon "xmark"}}
    </a>
  </template>
}
