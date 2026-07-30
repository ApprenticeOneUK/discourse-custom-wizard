import Component from "@glimmer/component";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

export default class PromptCompletionConnector extends Component {
  static shouldRender(_, context) {
    return (
      context.siteSettings.custom_wizard_enabled &&
      context.site.complete_custom_wizard
    );
  }

  @service site;

  <template>
    <div class="top-notices-outlet prompt-completion" ...attributes>
      {{#each this.site.complete_custom_wizard as |wizard|}}
        <div class="row">
          <div class="alert alert-info alert-wizard">
            <a href={{wizard.url}}>{{i18n
                "wizard.complete_custom"
                name=wizard.name
              }}</a>
          </div>
        </div>
      {{/each}}
    </div>
  </template>
}
