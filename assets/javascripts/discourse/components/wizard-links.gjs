/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { fn } from "@ember/helper";
import EmberObject, { action, computed } from "@ember/object";
import { trackedArray } from "@ember/reactive/collections";
import { trustHTML } from "@ember/template";
import { classNameBindings } from "@ember-decorators/component";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import { generateName } from "../lib/wizard";
import {
  default as wizardSchema,
  setWizardDefaults,
} from "../lib/wizard-schema";

@classNameBindings(":wizard-links", "itemType")
export default class WizardLinks extends Component {
  items = trackedArray();

  @computed("links.[]")
  get anyLinks() {
    return Boolean(this.links?.length);
  }

  updateItemOrder(itemId, newIndex) {
    const items = this.items;
    const itemIndex = items.findIndex((item) => item.id === itemId);
    if (itemIndex === -1) {
      return;
    }

    const [item] = items.splice(itemIndex, 1);
    item.set("index", newIndex);
    items.splice(newIndex, 0, item);
  }

  @computed("itemType")
  get header() {
    return `admin.wizard.${this.itemType}.header`;
  }

  @computed(
    "current",
    "items.@each.id",
    "items.@each.type",
    "items.@each.label",
    "items.@each.title"
  )
  get links() {
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

  getNextIndex() {
    const items = this.items;
    if (!items || items.length === 0) {
      return 0;
    }
    const numbers = items
      .map((item) => Number(item.id.split("_").pop()))
      .sort((a, b) => a - b);
    return numbers[numbers.length - 1];
  }

  setCurrent(item) {
    this.set("current", item);
    this.onChange?.(item);
  }

  @action
  add() {
    const items = this.items;
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
        params[objectArrays[objectType].property] = trackedArray();
      });
    }

    const newItem = EmberObject.create(params);
    items.push(newItem);

    this.setCurrent(newItem);
  }

  @action
  back(item) {
    this.updateItemOrder(item.id, item.index - 1);
  }

  @action
  forward(item) {
    this.updateItemOrder(item.id, item.index + 1);
  }

  @action
  change(itemId) {
    this.setCurrent(this.items.find((item) => item.id === itemId));
  }

  @action
  remove(itemId) {
    const items = this.items;
    const index = items.findIndex((item) => item.id === itemId);
    if (index === -1) {
      return;
    }

    let nextIndex;
    if (this.current.id === itemId) {
      nextIndex = index < items.length - 2 ? index + 1 : index - 1;
    }

    items.splice(index, 1);

    if (nextIndex) {
      this.setCurrent(items[nextIndex]);
    }
  }

  <template>
    <div class="wizard-header medium">
      {{trustHTML (i18n this.header)}}
    </div>

    <div class="link-list">
      {{#if this.anyLinks}}
        {{#each this.links as |link|}}
          <div data-id={{link.id}}>
            <DButton
              @action={{fn this.change link.id}}
              @translatedLabel={{link.label}}
              class={{link.classes}}
            />
            {{#unless link.first}}
              <DButton
                @action={{fn this.back link}}
                @icon="arrow-left"
                class="back"
              />
            {{/unless}}
            {{#unless link.last}}
              <DButton
                @action={{fn this.forward link}}
                @icon="arrow-right"
                class="forward"
              />
            {{/unless}}
            <DButton
              @action={{fn this.remove link.id}}
              @icon="xmark"
              class="remove"
            />
          </div>
        {{/each}}
      {{/if}}
      <DButton @action={{this.add}} @label="admin.wizard.add" @icon="plus" />
    </div>
  </template>
}
