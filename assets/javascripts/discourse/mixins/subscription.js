/* eslint-disable ember/no-new-mixins */
import { computed } from "@ember/object";
import { readOnly } from "@ember/object/computed";
import Mixin from "@ember/object/mixin";
import { getOwner } from "@ember/owner";

const PRODUCT_PAGE = "https://custom-wizard.pavilion.tech/pricing";
const SUPPORT_MESSAGE =
  "https://coop.pavilion.tech/new-message?username=support&title=Custom%20Wizard%20Support";
const MANAGER_CATEGORY =
  "https://pavilion.tech/products/discourse-custom-wizard-plugin/support";

export default Mixin.create({
  subscriptionLandingUrl: PRODUCT_PAGE,
  subscriptionClientUrl: "/admin/plugins/subscription-client",

  adminWizards: computed(function () {
    return getOwner(this).lookup("controller:admin-wizards");
  }),

  subscribed: readOnly("adminWizards.subscribed"),
  subscriptionType: readOnly("adminWizards.subscriptionType"),
  businessSubscription: readOnly("adminWizards.businessSubscription"),
  communitySubscription: readOnly("adminWizards.communitySubscription"),
  standardSubscription: readOnly("adminWizards.standardSubscription"),
  subscriptionAttributes: readOnly("adminWizards.subscriptionAttributes"),
  subscriptionClientInstalled: readOnly(
    "adminWizards.subscriptionClientInstalled"
  ),

  subscriptionLink: computed("subscriptionClientInstalled", function () {
    return this.subscriptionClientInstalled
      ? this.subscriptionClientUrl
      : this.subscriptionLandingUrl;
  }),

  subscriptionCtaLink: computed("subscriptionType", function () {
    switch (this.subscriptionType) {
      case "none":
        return PRODUCT_PAGE;
      case "standard":
        return SUPPORT_MESSAGE;
      case "business":
        return SUPPORT_MESSAGE;
      case "community":
        return MANAGER_CATEGORY;
      default:
        return PRODUCT_PAGE;
    }
  }),
});
