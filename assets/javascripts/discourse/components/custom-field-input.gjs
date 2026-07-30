/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component, { Input } from "@ember/component";
import { hash } from "@ember/helper";
import { action, computed } from "@ember/object";
import { classNames, tagName } from "@ember-decorators/component";
import MultiSelect from "discourse/select-kit/components/multi-select";
import DButton from "discourse/ui-kit/d-button";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import dLoadingSpinner from "discourse/ui-kit/helpers/d-loading-spinner";
import { i18n, i18n as i18n0 } from "discourse-i18n";
import WizardSubscriptionSelector from "./wizard-subscription-selector";

@tagName("tr")
@classNames("custom-field-input")
export default class CustomFieldInput extends Component {
  topicSerializers = ["topic_view", "topic_list_item"];
  postSerializers = ["post"];
  groupSerializers = ["basic_group"];
  categorySerializers = ["basic_category"];

  @computed("field.new", "field.edit")
  get showInputs() {
    return this.field.new || this.field.edit;
  }

  @computed("saving", "destroying")
  get loading() {
    return this.saving || this.destroying;
  }

  @computed("loading")
  get destroyDisabled() {
    return this.loading;
  }

  @computed("loading")
  get closeDisabled() {
    return this.loading;
  }

  @computed("field.id")
  get isExternal() {
    return this.field.id === "external";
  }

  didInsertElement() {
    super.didInsertElement(...arguments);
    this.set("originalField", JSON.parse(JSON.stringify(this.field)));
  }

  @computed("field.klass")
  get serializerContent() {
    const serializers = this.get(`${this.field.klass}Serializers`);

    if (serializers) {
      return serializers.reduce((result, key) => {
        result.push({
          id: key,
          name: i18n(`admin.wizard.custom_field.serializers.${key}`),
        });
        return result;
      }, []);
    }
  }

  @action
  updateFieldClass(klass) {
    this.set("field.klass", klass);
    this.set("field.serializers", null);
  }

  @action
  updateFieldType(type) {
    this.set("field.type", type);
  }

  @action
  updateFieldSerializers(serializers) {
    this.set("field.serializers", serializers);
  }

  compareArrays(array1, array2) {
    return (
      array1.length === array2.length &&
      array1.every((value, index) => {
        return value === array2[index];
      })
    );
  }

  @computed(
    "saving",
    "isExternal",
    "field.name",
    "field.klass",
    "field.type",
    "field.serializers"
  )
  get saveDisabled() {
    if (this.saving || this.isExternal) {
      return true;
    }

    const originalField = this.originalField;
    if (!originalField) {
      return false;
    }

    return ["name", "klass", "type", "serializers"].every((attr) => {
      let current = this.get(attr);
      let original = originalField[attr];

      if (!current) {
        return false;
      }

      if (attr === "serializers") {
        return this.compareArrays(current, original);
      } else {
        return current === original;
      }
    });
  }

  @action
  edit() {
    this.set("field.edit", true);
  }

  @action
  close() {
    if (this.field.edit) {
      this.set("field.edit", false);
    }
  }

  @action
  destroyField() {
    this.set("destroying", true);
    this.removeField(this.field);
  }

  @action
  save() {
    this.set("saving", true);

    const field = this.field;

    const data = {
      id: field.id,
      klass: field.klass,
      type: field.type,
      serializers: field.serializers,
      name: field.name,
    };

    this.saveField(data).then((result) => {
      this.set("saving", false);
      if (result.success) {
        this.set("field.edit", false);
      } else {
        this.set("saveIcon", "xmark");
      }
      setTimeout(() => {
        if (this.isDestroyed) {
          return;
        }
        this.set("saveIcon", null);
      }, 10000);
    });
  }

  <template>
    {{#if this.showInputs}}
      <td>
        <WizardSubscriptionSelector
          @value={{this.field.klass}}
          @feature="custom_field"
          @attribute="klass"
          @onChange={{this.updateFieldClass}}
          @options={{hash none="admin.wizard.custom_field.klass.select"}}
        />
      </td>
      <td>
        <WizardSubscriptionSelector
          @value={{this.field.type}}
          @feature="custom_field"
          @attribute="type"
          @onChange={{this.updateFieldType}}
          @options={{hash none="admin.wizard.custom_field.type.select"}}
        />
      </td>
      <td class="input">
        <Input
          @value={{this.field.name}}
          placeholder={{i18n0 "admin.wizard.custom_field.name.select"}}
        />
      </td>
      <td class="multi-select">
        <MultiSelect
          @value={{this.field.serializers}}
          @content={{this.serializerContent}}
          @onChange={{this.updateFieldSerializers}}
          @options={{hash none="admin.wizard.custom_field.serializers.select"}}
        />
      </td>
      <td class="actions">
        {{#if this.loading}}
          {{dLoadingSpinner size="small"}}
        {{else}}
          {{#if this.saveIcon}}
            {{dIcon this.saveIcon}}
          {{/if}}
        {{/if}}
        <DButton
          @action={{this.destroyField}}
          @icon="trash-can"
          class="destroy"
          @disabled={{this.destroyDisabled}}
        />
        <DButton
          @icon="floppy-disk"
          @action={{this.save}}
          @disabled={{this.saveDisabled}}
          class="save"
        />
        <DButton
          @action={{this.close}}
          @icon="xmark"
          @disabled={{this.closeDisabled}}
        />
      </td>
    {{else}}
      <td><label>{{this.field.klass}}</label></td>
      <td><label>{{this.field.type}}</label></td>
      <td class="input"><label>{{this.field.name}}</label></td>
      <td class="multi-select">
        {{#if this.isExternal}}
          &mdash;
        {{else}}
          {{#each this.field.serializers as |serializer|}}
            <label>{{serializer}}</label>
          {{/each}}
        {{/if}}
      </td>
      {{#if this.isExternal}}
        <td class="external">
          <label title={{i18n0 "admin.wizard.custom_field.external.title"}}>
            {{i18n0 "admin.wizard.custom_field.external.label"}}
          </label>
        </td>
      {{else}}
        <td class="actions">
          <DButton @action={{this.edit}} @icon="pencil" />
        </td>
      {{/if}}
    {{/if}}
  </template>
}
