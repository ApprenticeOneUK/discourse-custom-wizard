/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { computed } from "@ember/object";
import { trustHTML } from "@ember/template";
import { classNameBindings } from "@ember-decorators/component";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

const icons = {
  error: "circle-xmark",
  success: "circle-check",
  warn: "exclamation-circle",
  info: "circle-info",
};

@classNameBindings(":wizard-message", "type", "loading")
export default class WizardMessage extends Component {
  @computed("loading")
  get showDocumentation() {
    return !this.loading;
  }

  @computed("loading")
  get showIcon() {
    return !this.loading;
  }

  @computed("items.[]")
  get hasItems() {
    return Boolean(this.items?.length);
  }

  @computed("type")
  get icon() {
    return icons[this.type] || "circle-info";
  }

  @computed("key", "component", "opts")
  get message() {
    return i18n(
      `admin.wizard.message.${this.component}.${this.key}`,
      this.opts || {}
    );
  }

  @computed("component")
  get documentation() {
    return i18n(`admin.wizard.message.${this.component}.documentation`);
  }

  <template>
    <div class="message-block primary">
      {{#if this.showIcon}}
        {{dIcon this.icon}}
      {{/if}}
      <span class="message-content">{{trustHTML this.message}}</span>
      {{#if this.hasItems}}
        <ul>
          {{#each this.items as |item|}}
            <li>
              <span>{{dIcon item.icon}}</span>
              <span>{{trustHTML item.html}}</span>
            </li>
          {{/each}}
        </ul>
      {{/if}}
    </div>

    {{#if this.showDocumentation}}
      <div class="message-block">
        {{dIcon "circle-question"}}

        <a href={{this.url}} target="_blank" rel="noopener noreferrer">
          {{this.documentation}}
        </a>
      </div>
    {{/if}}
  </template>
}
