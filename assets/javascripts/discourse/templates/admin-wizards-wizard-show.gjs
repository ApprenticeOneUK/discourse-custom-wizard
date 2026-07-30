import { Input } from "@ember/component";
import { hash } from "@ember/helper";
import { on } from "@ember/modifier";
import ComboBox from "discourse/select-kit/components/combo-box";
import GroupChooser from "discourse/select-kit/components/group-chooser";
import DButton from "discourse/ui-kit/d-button";
import DConditionalLoadingSpinner from "discourse/ui-kit/d-conditional-loading-spinner";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";
import WizardCustomAction from "../components/wizard-custom-action";
import WizardCustomStep from "../components/wizard-custom-step";
import WizardLinks from "../components/wizard-links";
import WizardMapper from "../components/wizard-mapper";

export default <template>
  {{#if @controller.wizard}}
    <div class="wizard-header large">
      <Input
        @value={{@controller.wizard.name}}
        name="name"
        placeholder={{i18n "admin.wizard.name_placeholder"}}
        {{on "input" @controller.updateWizardName}}
      />

      <div class="wizard-url">
        {{#if @controller.wizard.name}}
          {{#if @controller.copiedUrl}}
            <DButton
              class="btn-hover pull-right"
              @icon="copy"
              @label="ip_lookup.copied"
            />
          {{else}}
            <DButton
              @action={{@controller.copyUrl}}
              class="pull-right no-text"
              @icon="copy"
            />
          {{/if}}
          <a
            href={{@controller.wizardUrl}}
            target="_blank"
            rel="noopener noreferrer"
          >{{@controller.wizardUrl}}</a>
        {{/if}}
      </div>
    </div>

    <div class="wizard-basic-details">
      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.background"}}</label>
        </div>
        <div class="setting-value">
          <Input
            @value={{@controller.wizard.background}}
            name="background"
            placeholder={{i18n "admin.wizard.background_placeholder"}}
            class="small"
          />
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.theme_id"}}</label>
        </div>
        <div class="setting-value">
          <ComboBox
            @content={{@controller.themes}}
            @valueProperty="id"
            @value={{@controller.wizard.theme_id}}
            @onChange={{@controller.updateThemeId}}
            @options={{hash none="admin.wizard.no_theme"}}
          />
        </div>
      </div>
    </div>

    <div class="wizard-header medium">
      {{i18n "admin.wizard.label"}}
    </div>

    <div class="wizard-settings">
      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.save_submissions"}}</label>
        </div>
        <div class="setting-value">
          <Input
            @type="checkbox"
            @checked={{@controller.wizard.save_submissions}}
          />
          <span>{{i18n "admin.wizard.save_submissions_label"}}</span>
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.multiple_submissions"}}</label>
        </div>
        <div class="setting-value">
          <Input
            @type="checkbox"
            @checked={{@controller.wizard.multiple_submissions}}
          />
          <span>{{i18n "admin.wizard.multiple_submissions_label"}}</span>
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.after_signup"}}</label>
        </div>
        <div class="setting-value">
          <Input
            @type="checkbox"
            @checked={{@controller.wizard.after_signup}}
          />
          <span>{{i18n "admin.wizard.after_signup_label"}}</span>
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.prompt_completion"}}</label>
        </div>
        <div class="setting-value">
          <Input
            @type="checkbox"
            @checked={{@controller.wizard.prompt_completion}}
          />
          <span>{{i18n "admin.wizard.prompt_completion_label"}}</span>
        </div>
      </div>

      <div class="setting full-inline">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.after_time"}}</label>
        </div>
        <div class="setting-value">
          <Input @type="checkbox" @checked={{@controller.wizard.after_time}} />
          <span>{{i18n "admin.wizard.after_time_label"}}</span>
          <DButton
            @action={{@controller.setNextSessionScheduled}}
            @translatedLabel={{@controller.nextSessionScheduledLabel}}
            class="btn-after-time"
            @icon="far-calendar"
          />
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.required"}}</label>
        </div>
        <div class="setting-value">
          <Input @type="checkbox" @checked={{@controller.wizard.required}} />
          <span>{{i18n "admin.wizard.required_label"}}</span>
        </div>
      </div>

      <div class="setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.restart_on_revisit"}}</label>
        </div>
        <div class="setting-value">
          <Input
            @type="checkbox"
            @checked={{@controller.wizard.restart_on_revisit}}
          />
          <span>{{i18n "admin.wizard.restart_on_revisit_label"}}</span>
        </div>
      </div>

      <div class="setting full field-mapper-setting">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.permitted"}}</label>
        </div>
        <div class="setting-value">
          <WizardMapper
            @inputs={{@controller.wizard.permitted}}
            @options={{hash
              context="wizard"
              inputTypes="assignment,validation"
              groupSelection="output"
              guestGroup=true
              userFieldSelection="key"
              textSelection="value"
              inputConnector="and"
            }}
          />
        </div>
      </div>

      <div class="setting full">
        <div class="setting-label">
          <label>{{i18n "admin.wizard.after_time_groups.label"}}</label>
        </div>
        <div class="setting-value">
          <GroupChooser
            @content={{@controller.site.groups}}
            @value={{@controller.afterTimeGroupIds}}
            @onChange={{@controller.setAfterTimeGroups}}
          />
          <div class="setting-gutter">
            {{i18n "admin.wizard.after_time_groups.description"}}
          </div>
        </div>
      </div>
    </div>

    <WizardLinks
      @itemType="step"
      @current={{@controller.currentStep}}
      @items={{@controller.wizard.steps}}
      @onChange={{@controller.setCurrentStep}}
    />

    {{#if @controller.currentStep}}
      <WizardCustomStep
        @step={{@controller.currentStep}}
        @wizard={{@controller.wizard}}
        @currentField={{@controller.currentField}}
        @wizardFields={{@controller.wizardFields}}
        @fieldTypes={{@controller.filteredFieldTypes}}
        @subscribed={{@controller.subscribed}}
        @setCurrentField={{@controller.setCurrentField}}
      />
    {{/if}}

    <WizardLinks
      @itemType="action"
      @current={{@controller.currentAction}}
      @items={{@controller.wizard.actions}}
      @generateLabels={{true}}
      @onChange={{@controller.setCurrentAction}}
    />

    {{#each @controller.wizard.actions as |wizardAction|}}
      <WizardCustomAction
        @action={{wizardAction}}
        @currentActionId={{@controller.currentAction.id}}
        @wizard={{@controller.wizard}}
        @apis={{@controller.apis}}
        @removeAction="removeAction"
        @wizardFields={{@controller.wizardFields}}
        @fieldTypes={{@controller.filteredFieldTypes}}
      />
    {{/each}}

    <div class="admin-wizard-buttons">
      <button
        {{on "click" @controller.save}}
        disabled={{@controller.disableSave}}
        class="btn btn-primary"
        type="button"
      >
        {{i18n "admin.wizard.save"}}
      </button>

      {{#unless @controller.creating}}
        <button
          {{on "click" @controller.remove}}
          class="btn btn-danger remove"
          type="button"
        >
          {{dIcon "far-trash-can"}}{{i18n "admin.wizard.remove"}}
        </button>
      {{/unless}}

      <DConditionalLoadingSpinner
        @condition={{@controller.saving}}
        @size="small"
      />

      {{#if @controller.error}}
        <span class="error">{{dIcon "xmark"}}{{@controller.error}}</span>
      {{/if}}
    </div>
  {{/if}}
</template>
