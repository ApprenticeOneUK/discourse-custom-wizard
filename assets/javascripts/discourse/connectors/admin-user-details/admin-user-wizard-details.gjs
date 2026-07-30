import { fn } from "@ember/helper";
import { LinkTo } from "@ember/routing";
import DButton from "discourse/ui-kit/d-button";
import dDasherize from "discourse/ui-kit/helpers/d-dasherize";
import { i18n } from "discourse-i18n";

export default <template>
  <div
    class="admin-user-details-outlet admin-user-wizard-details"
    ...attributes
  >
    <section class="details">
      <h1>{{i18n "admin.wizard.user.label"}}</h1>

      <div class="display-row">
        <div class="field">{{i18n "admin.wizard.user.redirect.label"}}</div>
        <div class="value">
          {{#if @outletArgs.model.redirect_to_wizard}}
            <LinkTo
              @route="adminWizardsWizardShow"
              @model={{dDasherize @outletArgs.model.redirect_to_wizard}}
            >
              {{@outletArgs.model.redirect_to_wizard}}
            </LinkTo>
          {{else}}
            &mdash;
          {{/if}}
        </div>
        <div class="controls">
          {{#if @outletArgs.model.redirect_to_wizard}}
            <DButton
              @action={{fn
                @outletArgs.model.clearWizardRedirect
                @outletArgs.model
              }}
              @label="admin.wizard.user.redirect.remove_label"
              @title="admin.wizard.user.redirect.remove_title"
            />
          {{/if}}
        </div>
      </div>
    </section>
  </div>
</template>
