/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action, computed, set } from "@ember/object";
import { trackedArray } from "@ember/reactive/collections";
import { classNameBindings } from "@ember-decorators/component";
import { observes } from "discourse/lib/decorators";
import {
  connectorContent,
  defaultConnector,
  defaultSelectionType,
  inputTypesContent,
  newPair,
} from "../lib/wizard-mapper";

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

  @observes("input.type")
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
}
