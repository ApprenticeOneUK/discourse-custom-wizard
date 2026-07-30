import { concat } from "@ember/helper";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import CustomFieldInput from "../components/custom-field-input";
import WizardMessage from "../components/wizard-message";

export default <template>
  <div class="admin-wizard-controls">
    <h3>{{i18n "admin.wizard.custom_field.nav_label"}}</h3>

    <div class="buttons">
      <DButton
        @label="admin.wizard.custom_field.add"
        @icon="plus"
        @action={{@controller.addField}}
      />
    </div>
  </div>

  <WizardMessage
    @key={{@controller.messageKey}}
    @opts={{@controller.messageOpts}}
    @type={{@controller.messageType}}
    @url={{@controller.documentationUrl}}
    @component="custom_fields"
  />

  <div class="admin-wizard-container">
    {{#if @controller.customFields}}
      <table>
        <thead>
          <tr>
            {{#each @controller.fieldKeys as |key|}}
              <th>{{i18n
                  (concat "admin.wizard.custom_field." key ".label")
                }}</th>
            {{/each}}
            <th></th>
          </tr>
        </thead>
        <tbody>
          {{#each @controller.customFields as |field|}}
            <CustomFieldInput
              @field={{field}}
              @removeField={{@controller.removeField}}
              @saveField={{@controller.saveField}}
            />
          {{/each}}
        </tbody>
      </table>
    {{/if}}
  </div>
</template>
