/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action, computed } from "@ember/object";
import { getOwner } from "@ember/owner";
import { dasherize } from "@ember/string";
import { classNameBindings } from "@ember-decorators/component";
import cookie from "discourse/lib/cookie";
import getURL from "discourse/lib/get-url";
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
}
