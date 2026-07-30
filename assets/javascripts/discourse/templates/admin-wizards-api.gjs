import { hash } from "@ember/helper";
import routeAction from "discourse/helpers/route-action";
import ComboBox from "discourse/select-kit/components/combo-box";
import DButton from "discourse/ui-kit/d-button";

export default <template>
  <div class="admin-wizard-controls">
    <ComboBox
      @value={{@controller.apiName}}
      @content={{@controller.apiList}}
      @onChange={{routeAction "changeApi"}}
      @options={{hash none="admin.wizard.api.select"}}
    />

    <DButton
      @action={{routeAction "createApi"}}
      @label="admin.wizard.api.create"
      @icon="plus"
    />
  </div>

  <div class="admin-wizard-container">
    {{outlet}}
  </div>
</template>
