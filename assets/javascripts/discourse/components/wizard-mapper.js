/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action, computed } from "@ember/object";
import { trackedArray } from "@ember/reactive/collections";
import { later } from "@ember/runloop";
import { classNames } from "@ember-decorators/component";
import { newInput, selectionTypes } from "../lib/wizard-mapper";

@classNames("wizard-mapper")
export default class WizardMapper extends Component {
  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);
    if (this.inputs && this.inputs.constructor !== Array) {
      later(() => this.set("inputs", null));
    }
  }

  @computed("inputs.@each.type")
  get canAdd() {
    return (
      !this.inputs ||
      this.inputs.constructor !== Array ||
      this.inputs.every((input) => {
        return !["assignment", "association"].includes(input.type);
      })
    );
  }

  @computed("options")
  get inputOptions() {
    const result = {
      inputTypes: this.options.inputTypes || "assignment,conditional",
      inputConnector: this.options.inputConnector || "or",
      pairConnector: this.options.pairConnector || null,
      outputConnector: this.options.outputConnector || null,
      context: this.options.context || null,
      guestGroup: this.options.guestGroup || false,
      includeMessageableGroups: this.options.includeMessageableGroups || false,
      userLimit: this.options.userLimit || null,
    };

    const inputTypes = ["key", "value", "output"];
    inputTypes.forEach((type) => {
      result[`${type}Placeholder`] = this.options[`${type}Placeholder`] || null;
      result[`${type}DefaultSelection`] =
        this.options[`${type}DefaultSelection`] || null;
    });

    selectionTypes.forEach((type) => {
      if (this.options[`${type}Selection`] !== undefined) {
        result[`${type}Selection`] = this.options[`${type}Selection`];
      } else {
        result[`${type}Selection`] = type === "text";
      }
    });

    return result;
  }

  onUpdate() {}

  @action
  add() {
    if (!this.inputs) {
      this.set("inputs", trackedArray());
    }

    this.inputs.push(newInput(this.inputOptions, this.inputs.length));

    this.onUpdate(this.property, "input");
  }

  @action
  remove(input) {
    const inputs = this.inputs;
    const index = inputs.indexOf(input);
    if (index !== -1) {
      inputs.splice(index, 1);
    }

    if (inputs.length) {
      inputs[0].set("connector", null);
    }

    this.onUpdate(this.property, "input");
  }

  @action
  inputUpdated(component, type) {
    this.onUpdate(this.property, component, type);
  }
}
