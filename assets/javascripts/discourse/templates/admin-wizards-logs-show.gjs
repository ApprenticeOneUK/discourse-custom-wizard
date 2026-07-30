import DButton from "discourse/ui-kit/d-button";
import DConditionalLoadingSpinner from "discourse/ui-kit/d-conditional-loading-spinner";
import DLoadMore from "discourse/ui-kit/d-load-more";
import { i18n } from "discourse-i18n";
import WizardTableField from "../components/wizard-table-field";

export default <template>
  {{#if @controller.logs}}
    <div class="wizard-header large">
      <label>
        {{i18n "admin.wizard.log.title" name=@controller.wizard.name}}
      </label>

      <div class="controls">
        <DButton
          @label="refresh"
          @icon="arrows-rotate"
          @action={{@controller.refresh}}
          class="refresh"
        />
      </div>
    </div>

    <div class="wizard-table">
      <DLoadMore @selector=".wizard-table tr" @action={{@controller.loadMore}}>
        {{#if @controller.noResults}}
          <p>{{i18n "search.no_results"}}</p>
        {{else}}
          <table>
            <thead>
              <tr>
                <th class="date">{{i18n "admin.wizard.log.date"}}</th>
                <th>{{i18n "admin.wizard.log.action"}}</th>
                <th>{{i18n "admin.wizard.log.user"}}</th>
                <th>{{i18n "admin.wizard.log.message"}}</th>
              </tr>
            </thead>
            <tbody>
              {{#each @controller.logs as |entry|}}
                <tr>
                  {{#if entry}}
                    {{#each-in entry as |field value|}}
                      <td class="small"><WizardTableField
                          @field={{field}}
                          @value={{value}}
                        /></td>
                    {{/each-in}}
                  {{/if}}
                </tr>
              {{/each}}
            </tbody>
          </table>
        {{/if}}

        <DConditionalLoadingSpinner @condition={{@controller.refreshing}} />
      </DLoadMore>
    </div>
  {{/if}}
</template>
