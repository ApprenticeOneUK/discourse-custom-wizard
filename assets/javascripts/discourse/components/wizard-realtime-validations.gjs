/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component, { Input } from "@ember/component";
import { concat, fn, get } from "@ember/helper";
import EmberObject, { action, computed } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import { cloneJSON } from "discourse/lib/object";
import Category from "discourse/models/category";
import CategorySelector from "discourse/select-kit/components/category-selector";
import ComboBox from "discourse/select-kit/components/combo-box";
import DRadioButton from "discourse/ui-kit/d-radio-button";
import { i18n, i18n as i18n0 } from "discourse-i18n";

@classNames("realtime-validations", "setting", "full", "subscription")
export default class WizardRealtimeValidations extends Component {
  init() {
    super.init(...arguments);
    if (!this.validations) {
      return;
    }

    if (!this.field.validations) {
      const validations = {};

      this.validations.forEach((validation) => {
        validations[validation] = {};
      });

      this.set("field.validations", EmberObject.create(validations));
    }

    const validationBuffer = cloneJSON(this.get("field.validations"));
    if (validationBuffer.similar_topics) {
      const bufferCategories = validationBuffer.similar_topics.categories || [];
      validationBuffer.similar_topics.categories =
        Category.findByIds(bufferCategories);
    }
    this.set("validationBuffer", validationBuffer);
  }

  get timeUnits() {
    return ["days", "weeks", "months", "years"].map((unit) => {
      return {
        id: unit,
        name: i18n(`admin.wizard.field.validations.time_units.${unit}`),
      };
    });
  }

  @computed("field.validations")
  get validationRows() {
    if (!this.field.validations) {
      return [];
    }

    return Object.keys(this.field.validations).map((type) => ({
      type,
      props: this.field.validations[type],
      isSimilarTopics: type === "similar_topics",
      isAnswer: type === "answer",
    }));
  }

  @action
  updateValidationCategories(type, categories) {
    this.set(`validationBuffer.${type}.categories`, categories);
    this.set(
      `field.validations.${type}.categories`,
      categories.map((category) => category.id)
    );
  }

  @action
  updateTimeUnit(type, timeUnit) {
    this.set(`field.validations.${type}.time_unit`, timeUnit);
  }

  <template>
    <div class="setting-label">
      <label>{{i18n0 "admin.wizard.field.validations.header"}}</label>
    </div>
    <div class="setting-value full">
      <ul>
        {{#each this.validationRows as |row|}}
          <li>
            <span class="setting-title">
              <h4>{{i18n0
                  (concat "admin.wizard.field.validations." row.type)
                }}</h4>
              <Input @type="checkbox" @checked={{row.props.status}} />
              {{i18n0 "admin.wizard.field.validations.enabled"}}
            </span>
            <div class="validation-container">
              {{#if row.isSimilarTopics}}
                <div class="validation-section">
                  <div class="setting-label">
                    <label>{{i18n0
                        "admin.wizard.field.validations.categories"
                      }}</label>
                  </div>
                  <div class="setting-value">
                    <CategorySelector
                      @categories={{get
                        this
                        (concat "validationBuffer." row.type ".categories")
                      }}
                      @onChange={{fn this.updateValidationCategories row.type}}
                      class="wizard"
                    />
                  </div>
                </div>
                <div class="validation-section">
                  <div class="setting-label">
                    <label>{{i18n0
                        "admin.wizard.field.validations.max_topic_age"
                      }}</label>
                  </div>
                  <div class="setting-value">
                    <Input
                      @type="number"
                      @value={{row.props.time_n_value}}
                      class="time-n-value"
                    />
                    <ComboBox
                      @value={{readonly row.props.time_unit}}
                      @content={{this.timeUnits}}
                      @class="time-unit-selector"
                      @onChange={{fn this.updateTimeUnit row.type}}
                    />
                  </div>
                </div>
                <div class="validation-section">
                  <div class="setting-label">
                    <label>{{i18n0
                        "admin.wizard.field.validations.position"
                      }}</label>
                  </div>
                  <div class="setting-value">
                    <DRadioButton
                      @name={{concat row.type this.field.id}}
                      @value="above"
                      @selection={{row.props.position}}
                    />
                    <span>{{i18n0
                        "admin.wizard.field.validations.above"
                      }}</span>
                    <DRadioButton
                      @name={{concat row.type this.field.id}}
                      @value="below"
                      @selection={{row.props.position}}
                    />
                    <span>{{i18n0
                        "admin.wizard.field.validations.below"
                      }}</span>
                  </div>
                </div>
              {{/if}}

              {{#if row.isAnswer}}
                <div class="validation-section">
                  <div class="setting-label">
                    <label>{{i18n0
                        "admin.wizard.field.validations.expected"
                      }}</label>
                  </div>
                  <div class="setting-value">
                    <Input
                      @type="text"
                      @value={{row.props.expected}}
                      class="answer-expected"
                    />
                    <div class="instructions">
                      {{i18n0
                        "admin.wizard.field.validations.expected_instructions"
                      }}
                    </div>
                  </div>
                </div>
                <div class="validation-section">
                  <div class="setting-label">
                    <label>{{i18n0
                        "admin.wizard.field.validations.match"
                      }}</label>
                  </div>
                  <div class="setting-value">
                    <DRadioButton
                      @name={{concat "match" row.type this.field.id}}
                      @value="exact"
                      @selection={{row.props.match}}
                    />
                    <span>{{i18n0
                        "admin.wizard.field.validations.match_exact"
                      }}</span>
                    <DRadioButton
                      @name={{concat "match" row.type this.field.id}}
                      @value="insensitive"
                      @selection={{row.props.match}}
                    />
                    <span>{{i18n0
                        "admin.wizard.field.validations.match_insensitive"
                      }}</span>
                  </div>
                </div>
                <div class="validation-section">
                  <div class="setting-label">
                    <label>{{i18n0
                        "admin.wizard.field.validations.message"
                      }}</label>
                  </div>
                  <div class="setting-value">
                    <Input
                      @type="text"
                      @value={{row.props.message}}
                      class="answer-message"
                      placeholder={{i18n0
                        "admin.wizard.field.validations.message_placeholder"
                      }}
                    />
                  </div>
                </div>
              {{/if}}
            </div>
          </li>
        {{/each}}
      </ul>
    </div>
  </template>
}
