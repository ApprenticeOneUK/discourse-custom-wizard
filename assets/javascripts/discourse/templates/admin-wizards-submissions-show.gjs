import DButton from "discourse/ui-kit/d-button";
import DConditionalLoadingSpinner from "discourse/ui-kit/d-conditional-loading-spinner";
import DLoadMore from "discourse/ui-kit/d-load-more";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";
import WizardTableField from "../components/wizard-table-field";

export default <template>
  {{#if @controller.submissions}}
    <div class="wizard-header large">
      <label>
        {{i18n "admin.wizard.submissions.title" name=@controller.wizard.name}}
      </label>

      <div class="controls">
        <DButton
          @icon="sliders"
          @label="admin.wizard.edit_columns"
          @action={{@controller.showEditColumnsModal}}
          class="btn-default open-edit-columns-btn download-link"
        />
      </div>

      <a
        class="btn btn-default download-link"
        href={{@controller.downloadUrl}}
        target="_blank"
        rel="noopener noreferrer"
      >
        {{dIcon "download"}}
        <span class="d-button-label">
          {{i18n "admin.wizard.submissions.download"}}
        </span>
      </a>
    </div>

    <div class="wizard-table">
      <DLoadMore @selector=".wizard-table tr" @action={{@controller.loadMore}}>
        {{#if @controller.noResults}}
          <p>{{i18n "search.no_results"}}</p>
        {{else}}
          <table>
            <thead>
              <tr>
                {{#each @controller.fields as |field|}}
                  {{#if field.enabled}}
                    <th>
                      {{field.label}}
                    </th>
                  {{/if}}
                {{/each}}
              </tr>
            </thead>
            <tbody>
              {{#each @controller.displaySubmissions as |submission|}}
                <tr>
                  {{#each-in submission as |field value|}}
                    <td><WizardTableField
                        @field={{field}}
                        @value={{value}}
                      /></td>
                  {{/each-in}}
                </tr>
              {{/each}}
            </tbody>
          </table>
        {{/if}}

        <DConditionalLoadingSpinner @condition={{@controller.loadingMore}} />
      </DLoadMore>
    </div>
  {{/if}}
</template>
