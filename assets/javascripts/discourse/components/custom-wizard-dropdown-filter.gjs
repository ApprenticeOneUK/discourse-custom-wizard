import { Input } from "@ember/component";
import { on } from "@ember/modifier";
import {
  attributeBindings,
  classNameBindings,
  classNames,
} from "@ember-decorators/component";
import SelectKitFilter from "discourse/select-kit/components/select-kit/select-kit-filter";
import dIcon from "discourse/ui-kit/helpers/d-icon";

@classNames("select-kit-filter")
@classNameBindings("isExpanded:is-expanded")
@attributeBindings("role")
export default class CustomWizardDropdownFilter extends SelectKitFilter {
  get filterAriaLabel() {
    return this.selectKit.options.filterAriaLabel || this.placeholder;
  }

  <template>
    {{#unless this.isHidden}}
      {{! filter-input-search prevents 1password from attempting autocomplete }}
      <Input
        tabindex={{0}}
        class="filter-input"
        aria-label={{this.filterAriaLabel}}
        placeholder={{this.placeholder}}
        autocomplete="off"
        autocorrect="off"
        autocapitalize="off"
        name="filter-input-search"
        spellcheck={{false}}
        @value={{readonly this.selectKit.filter}}
        @type="search"
        {{on "paste" this.onPaste}}
        {{on "keydown" this.onKeydown}}
        {{on "keyup" this.onKeyup}}
        {{on "input" this.onInput}}
      />

      {{#if this.selectKit.options.filterIcon}}
        {{dIcon this.selectKit.options.filterIcon class="filter-icon"}}
      {{/if}}
    {{/unless}}
  </template>
}
