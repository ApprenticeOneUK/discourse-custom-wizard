/* eslint-disable discourse/discourse-common-imports, discourse/ui-kit-imports */
import DateInput from "discourse/components/date-input";
import discourseComputed from "discourse-common/utils/decorators";

export default DateInput.extend({
  useNativePicker: false,

  @discourseComputed()
  placeholder() {
    return this.format;
  },
  _opts() {
    return {
      format: this.format || "LL",
    };
  },
});
