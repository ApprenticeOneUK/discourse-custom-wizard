/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action, computed } from "@ember/object";
import { classNames, tagName } from "@ember-decorators/component";
import { observes } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";

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

  @observes("field.klass")
  clearSerializersWhenClassChanges() {
    this.set("field.serializers", null);
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
}
