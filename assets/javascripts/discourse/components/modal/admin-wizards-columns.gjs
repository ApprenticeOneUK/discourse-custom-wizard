import Component from "@glimmer/component";
import { Input } from "@ember/component";
import { action } from "@ember/object";
import directoryTableHeaderTitle from "discourse/helpers/directory-table-header-title";
import DButton from "discourse/ui-kit/d-button";
import DModal from "discourse/ui-kit/d-modal";
import dLoadingSpinner from "discourse/ui-kit/helpers/d-loading-spinner";
import { i18n } from "discourse-i18n";

export default class AdminWizardsColumnComponent extends Component {
  title = i18n("admin.wizard.edit_columns");

  @action
  save() {
    this.args.closeModal();
  }

  @action
  resetToDefault() {
    this.args.model.reset();
  }

  <template>
    <DModal @closeModal={{@closeModal}} @title={{this.title}}>
      <:body>
        {{#if this.loading}}
          {{dLoadingSpinner size="large"}}
        {{else}}
          <div class="edit-directory-columns-container">
            {{#each @model.columns as |column|}}
              <div class="edit-directory-column">
                <div class="left-content">
                  <label class="column-name">
                    <Input @type="checkbox" @checked={{column.enabled}} />
                    {{directoryTableHeaderTitle
                      field=column.label
                      translated=true
                    }}
                  </label>
                </div>
              </div>
            {{/each}}
          </div>
        {{/if}}
      </:body>

      <:footer>
        <DButton
          @label="directory.edit_columns.save"
          @action={{this.save}}
          class="btn-primary"
        />
        <DButton
          @label="directory.edit_columns.reset_to_default"
          @action={{this.resetToDefault}}
          class="btn-secondary reset-to-default"
        />
      </:footer>
    </DModal>
  </template>
}
