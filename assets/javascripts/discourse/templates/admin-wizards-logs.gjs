import { hash } from "@ember/helper";
import routeAction from "discourse/helpers/route-action";
import ComboBox from "discourse/select-kit/components/combo-box";
import WizardMessage from "../components/wizard-message";

export default <template>
  <div class="admin-wizard-select admin-wizard-controls">
    <ComboBox
      @value={{@controller.wizardId}}
      @content={{@controller.wizardList}}
      @onChange={{routeAction "changeWizard"}}
      @options={{hash none="admin.wizard.select"}}
    />
  </div>

  <WizardMessage
    @key={{@controller.messageKey}}
    @opts={{@controller.messageOpts}}
    @url={{@controller.documentationUrl}}
    @component="logs"
  />

  <div class="admin-wizard-container">
    {{outlet}}
  </div>
</template>
