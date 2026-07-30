import { computed } from "@ember/object";
import { service } from "@ember/service";
import { classNames } from "@ember-decorators/component";
import { selectKitOptions } from "discourse/select-kit/components/select-kit";
import SingleSelectComponent from "discourse/select-kit/components/single-select";
import { i18n } from "discourse-i18n";
import { filterValues } from "discourse/plugins/discourse-custom-wizard/discourse/lib/wizard-schema";

const nameKey = function (feature, attribute, value) {
  if (feature === "action") {
    return `admin.wizard.action.${value}.label`;
  } else {
    return `admin.wizard.${feature}.${attribute}.${value}`;
  }
};

@classNames("combo-box", "wizard-subscription-selector")
@selectKitOptions({
  autoFilterable: false,
  filterable: false,
  showFullTitle: true,
  headerComponent:
    "wizard-subscription-selector/wizard-subscription-selector-header",
  caretUpIcon: "caret-up",
  caretDownIcon: "caret-down",
})
export default class WizardSubscriptionSelector extends SingleSelectComponent {
  @service subscription;

  allowedSubscriptionTypes(feature, attribute, value) {
    let attributes = this.subscription.subscriptionAttributes[feature];
    if (!attributes || !attributes[attribute]) {
      return ["none"];
    }
    let allowedTypes = [];
    Object.keys(attributes[attribute]).forEach((subscriptionType) => {
      let values = attributes[attribute][subscriptionType];
      if (values[0] === "*" || values.includes(value)) {
        allowedTypes.push(subscriptionType);
      }
    });
    return allowedTypes;
  }

  @computed("feature", "attribute", "wizard.allowGuests")
  get content() {
    return filterValues(this.wizard, this.feature, this.attribute)
      .map((value) => {
        const allowedSubscriptionTypes = this.allowedSubscriptionTypes(
          this.feature,
          this.attribute,
          value
        );

        const subscriptionRequired = false;

        const attrs = {
          id: value,
          name: i18n(nameKey(this.feature, this.attribute, value)),
          subscriptionRequired,
        };
        if (subscriptionRequired) {
          const subscribed = allowedSubscriptionTypes.includes(
            this.subscription.subscriptionType
          );
          const selectorKey = subscribed ? "subscribed" : "not_subscribed";
          const selectorLabel = `admin.wizard.subscription.${selectorKey}.selector`;

          attrs.disabled = !subscribed;
          attrs.selectorLabel = selectorLabel;
        }

        return attrs;
      })
      .sort(function (a, b) {
        if (a.subscriptionType && !b.subscriptionType) {
          return 1;
        }
        if (!a.subscriptionType && b.subscriptionType) {
          return -1;
        }
        if (a.subscriptionType === b.subscriptionType) {
          return a.subscriptionType
            ? a.subscriptionType.localeCompare(b.subscriptionType)
            : 0;
        } else {
          return a.subscriptionType === "standard" ? -1 : 0;
        }
      });
  }

  modifyComponentForRow() {
    return "wizard-subscription-selector/wizard-subscription-selector-row";
  }
}
