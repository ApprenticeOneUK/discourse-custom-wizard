/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { on } from "@ember/modifier";
import { action, computed } from "@ember/object";
import { getOwner } from "@ember/owner";
import { dasherize } from "@ember/string";
import { classNameBindings } from "@ember-decorators/component";
import cookie from "discourse/lib/cookie";
import getURL from "discourse/lib/get-url";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import CustomWizard from "../models/custom-wizard";

@classNameBindings(":wizard-no-access", "reasonClass")
export default class CustomWizardNoAccess extends Component {
  @computed("reason")
  get reasonClass() {
    return dasherize(this.reason);
  }

  get siteName() {
    return this.siteSettings.title || "";
  }

  @computed("reason")
  get showLoginButton() {
    return this.reason === "requiresLogin";
  }

  @action
  skip() {
    if (this.currentUser) {
      CustomWizard.skip(this.wizardId);
    } else {
      window.location = getURL("/");
    }
  }

  @action
  showLogin() {
    cookie("destination_url", getURL(`/w/${this.wizardId}`));
    getOwner(this).lookup("route:application").send("showLogin");
  }

  <template>
    <div>{{this.text}}</div>
    <div class="no-access-gutter">
      <a class="return-to-site" {{on "click" this.skip}} role="button">
        {{i18n "wizard.return_to_site" siteName=this.siteName}}
      </a>
      {{#if this.showLoginButton}}
        <DButton
          class="btn-primary btn-small login-button"
          @action={{this.showLogin}}
          @label="log_in"
          @icon="user"
        />
      {{/if}}
    </div>
  </template>
}
