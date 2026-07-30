/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { computed } from "@ember/object";
import { classNameBindings, classNames } from "@ember-decorators/component";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";

@classNames("validator")
@classNameBindings("isValid", "isInvalid")
export default class Validator extends Component {
  validMessageKey = null;
  invalidMessageKey = null;
  isValid = null;

  init() {
    super.init(...arguments);

    if (this.get("validation.backend")) {
      // set a function that can be called as often as it need to
      // from the derived component
      this.backendValidate = (params) => {
        return ajax("/realtime-validations", {
          data: {
            type: this.get("type"),
            ...params,
          },
        });
      };
    }
  }

  @computed("isValid")
  get isInvalid() {
    return this.isValid === false;
  }

  didInsertElement() {
    super.didInsertElement(...arguments);
    this.appEvents.on("custom-wizard:validate", this, this.checkIsValid);
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    this.appEvents.off("custom-wizard:validate", this, this.checkIsValid);
  }

  checkIsValid() {
    this.set("isValid", this.validate());
  }

  <template>
    {{#if this.isValid}}
      {{i18n this.validMessageKey}}
    {{else}}
      {{i18n this.invalidMessageKey}}
    {{/if}}
  </template>
}
