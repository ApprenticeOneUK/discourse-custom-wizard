import { computed } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import { resolveComponent } from "discourse/select-kit/components/select-kit";
import SingleSelectHeaderComponent from "discourse/select-kit/components/select-kit/single-select-header";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

@classNames("combo-box-header", "wizard-subscription-selector-header")
export default class WizardSubscriptionSelectorHeader extends SingleSelectHeaderComponent {
  @computed("selectKit.options.caretUpIcon")
  get caretUpIcon() {
    return this.selectKit.options.caretUpIcon;
  }

  @computed("selectKit.options.caretDownIcon")
  get caretDownIcon() {
    return this.selectKit.options.caretDownIcon;
  }

  @computed("selectKit.isExpanded", "caretUpIcon", "caretDownIcon")
  get caretIcon() {
    return this.selectKit.isExpanded ? this.caretUpIcon : this.caretDownIcon;
  }

  <template>
    <div class="select-kit-header-wrapper">
      {{#let
        (resolveComponent this this.selectKit.options.selectedNameComponent)
        as |SelectedNameComponent|
      }}
        <SelectedNameComponent
          @tabindex={{this.tabindex}}
          @item={{this.selectedContent}}
          @selectKit={{this.selectKit}}
          @shouldDisplayClearableButton={{this.shouldDisplayClearableButton}}
        />
      {{/let}}

      {{#if this.subscriptionRequired}}
        <span class="subscription-label">{{i18n this.selectorLabel}}</span>
      {{/if}}

      {{dIcon this.caretIcon class="caret-icon"}}
    </div>
  </template>
}
