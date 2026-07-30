import { computed } from "@ember/object";

export const States = {
  UNCHECKED: 0,
  INVALID: 1,
  VALID: 2,
};

export default {
  _validState: null,
  errorDescription: null,

  init() {
    this._super(...arguments);
    this.set("_validState", States.UNCHECKED);
  },

  valid: computed("_validState", function () {
    return this._validState === States.VALID;
  }),

  invalid: computed("_validState", function () {
    return this._validState === States.INVALID;
  }),

  unchecked: computed("_validState", function () {
    return this._validState === States.UNCHECKED;
  }),

  setValid(valid, description) {
    this.set("_validState", valid ? States.VALID : States.INVALID);

    if (!valid && description && description.length) {
      this.set("errorDescription", description);
    } else {
      this.set("errorDescription", null);
    }
  },
};
