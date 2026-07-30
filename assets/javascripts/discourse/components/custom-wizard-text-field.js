import { computed } from "@ember/object";
import { attributeBindings } from "@ember-decorators/component";
import { isLTR, isRTL, siteDir } from "discourse/lib/text-direction";
import DTextField from "discourse/ui-kit/d-text-field";
import { i18n } from "discourse-i18n";

@attributeBindings(
  "autocorrect",
  "autocapitalize",
  "autofocus",
  "maxLength",
  "dir"
)
export default class CustomWizardTextField extends DTextField {
  @computed
  get dir() {
    if (this.siteSettings.support_mixed_text_direction) {
      let val = this.value;
      if (val) {
        return isRTL(val) ? "rtl" : "ltr";
      } else {
        return siteDir();
      }
    }
  }

  keyUp() {
    if (this.siteSettings.support_mixed_text_direction) {
      let val = this.value;
      if (isRTL(val)) {
        this.set("dir", "rtl");
      } else if (isLTR(val)) {
        this.set("dir", "ltr");
      } else {
        this.set("dir", siteDir());
      }
    }
  }

  @computed("placeholderKey")
  get placeholder() {
    return this.placeholderKey ? i18n(this.placeholderKey) : "";
  }
}
