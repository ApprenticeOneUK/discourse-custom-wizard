/* eslint-disable ember/no-actions-hash, ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
// eslint-disable-next-line discourse/deprecated-imports -- preserve observable arrays used by this legacy component
import { A } from "@ember/array";
import Component from "@ember/component";
import EmberObject, { computed } from "@ember/object";
import { notEmpty } from "@ember/object/computed";
import { generateName } from "../lib/wizard";
import {
  default as wizardSchema,
  setWizardDefaults,
} from "../lib/wizard-schema";

export default Component.extend({
  classNameBindings: [":wizard-links", "itemType"],
  items: A(),
  anyLinks: notEmpty("links"),

  updateItemOrder(itemId, newIndex) {
    const items = this.items;
    const item = items.findBy("id", itemId);
    items.removeObject(item);
    item.set("index", newIndex);
    items.insertAt(newIndex, item);
  },

  header: computed("itemType", function () {
    return `admin.wizard.${this.itemType}.header`;
  }),

  links: computed(
    "current",
    "items.@each.id",
    "items.@each.type",
    "items.@each.label",
    "items.@each.title",
    function () {
      const current = this.current;
      const items = this.items;

      if (!items) {
        return;
      }

      return items.map((item, index) => {
        if (item) {
          const link = {
            id: item.id,
          };

          let label = item.label || item.title || item.id;
          if (this.generateLabels && item.type) {
            label = generateName(item.type);
          }

          link.label = `${label} (${item.id})`;

          let classes = "btn";
          if (current && item.id === current.id) {
            classes += " btn-primary";
          }

          link.classes = classes;
          link.index = index;

          if (index === 0) {
            link.first = true;
          }

          if (index === items.length - 1) {
            link.last = true;
          }

          return link;
        }
      });
    }
  ),

  getNextIndex() {
    const items = this.items;
    if (!items || items.length === 0) {
      return 0;
    }
    const numbers = items
      .map((item) => Number(item.id.split("_").pop()))
      .sort((a, b) => a - b);
    return numbers[numbers.length - 1];
  },

  actions: {
    add() {
      const items = this.get("items");
      const itemType = this.itemType;
      const params = setWizardDefaults({}, itemType);

      params.isNew = true;
      params.index = this.getNextIndex();

      let id = `${itemType}_${params.index + 1}`;
      if (itemType === "field") {
        id = `${this.parentId}_${id}`;
      }

      params.id = id;

      const objectArrays = wizardSchema[itemType].objectArrays;
      if (objectArrays) {
        Object.keys(objectArrays).forEach((objectType) => {
          params[objectArrays[objectType].property] = A();
        });
      }

      const newItem = EmberObject.create(params);
      items.pushObject(newItem);

      this.set("current", newItem);
    },

    back(item) {
      this.updateItemOrder(item.id, item.index - 1);
    },

    forward(item) {
      this.updateItemOrder(item.id, item.index + 1);
    },

    change(itemId) {
      this.set("current", this.items.findBy("id", itemId));
    },

    remove(itemId) {
      const items = this.items;
      let item;
      let index;

      items.forEach((candidate, candidateIndex) => {
        if (candidate.id === itemId) {
          item = candidate;
          index = candidateIndex;
        }
      });

      let nextIndex;
      if (this.current.id === itemId) {
        nextIndex = index < items.length - 2 ? index + 1 : index - 1;
      }

      items.removeObject(item);

      if (nextIndex) {
        this.set("current", items[nextIndex]);
      }
    },
  },
});
