import { i18n } from "discourse-i18n";
import CustomWizardNoAccess from "../../components/custom-wizard-no-access";

export default <template>
  {{#if @controller.noAccess}}
    <CustomWizardNoAccess
      @text={{i18n @controller.noAccessI18nKey}}
      @wizardId={{@controller.wizardId}}
      @reason={{@controller.noAccessReason}}
    />
  {{/if}}
</template>
