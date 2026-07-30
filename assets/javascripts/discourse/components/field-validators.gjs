/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { hash } from "@ember/helper";
import { action, computed } from "@ember/object";
import { getOwner } from "@ember/owner";

export default class FieldValidators extends Component {
  buildValidations(position) {
    return Object.entries(this.field.validations[position] || {}).map(
      ([type, validation]) => ({
        component: getOwner(this).resolveRegistration(
          `component:${validation.component}`
        ),
        type,
        validation,
      })
    );
  }

  @computed("field.validations.above")
  get aboveValidations() {
    return this.buildValidations("above");
  }

  @computed("field.validations.below")
  get belowValidations() {
    return this.buildValidations("below");
  }

  @action
  perform() {
    this.appEvents.trigger("custom-wizard:validate");
  }

  <template>
    {{#if this.field.validations}}
      {{#each this.aboveValidations as |entry|}}
        <entry.component
          @field={{this.field}}
          @type={{entry.type}}
          @validation={{entry.validation}}
        />
      {{/each}}

      {{yield (hash perform=this.perform autocomplete="off")}}

      {{#each this.belowValidations as |entry|}}
        <entry.component
          @field={{this.field}}
          @type={{entry.type}}
          @validation={{entry.validation}}
        />
      {{/each}}
    {{else}}
      {{yield}}
    {{/if}}
  </template>
}
