import { computed } from "@ember/object";
import { dasherize } from "@ember/string";
import { trustHTML } from "@ember/template";
import { classNameBindings } from "@ember-decorators/component";
import SelectKitRowComponent from "discourse/select-kit/components/select-kit/select-kit-row";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

@classNameBindings("isDisabled:disabled")
export default class WizardSubscriptionSelectorRow extends SelectKitRowComponent {
  @computed("item")
  get isDisabled() {
    return this.item.disabled;
  }

  click(event) {
    event.preventDefault();
    event.stopPropagation();
    if (!this.item.disabled) {
      this.selectKit.select(this.rowValue, this.item);
    }
    return false;
  }

  <template>
    {{#if this.icons}}
      <div class="icons">
        <span class="selection-indicator"></span>
        {{#each this.icons as |icon|}}
          {{dIcon icon translatedtitle=(dasherize this.title)}}
        {{/each}}
      </div>
    {{/if}}

    <div class="texts">
      <span class="name">{{trustHTML this.label}}</span>
      {{#if this.item.subscriptionRequired}}
        <span class="subscription-label">
          {{i18n this.item.selectorLabel}}
        </span>
      {{/if}}
    </div>
  </template>
}
