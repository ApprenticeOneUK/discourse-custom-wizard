/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import Category from "discourse/models/category";
import CustomWizardCategorySelector from "./custom-wizard-category-selector";

export default class CustomWizardFieldCategory extends Component {
  categories = [];

  didInsertElement() {
    super.didInsertElement(...arguments);
    const property = this.field.property || "id";
    const value = this.field.value;

    if (value) {
      const categories = [...value].reduce((result, v) => {
        const category =
          property === "id" ? Category.findById(v) : Category.findBySlug(v);
        if (category) {
          result.push(category);
        }
        return result;
      }, []);

      this.updateCategories(categories);
    }
  }

  @action
  updateCategories(value) {
    this.set("categories", value);

    const categories = (value || []).filter((category) => category);
    const property = this.field.property || "id";

    if (categories.length) {
      this.set(
        "field.value",
        categories.reduce((result, c) => {
          if (c && c[property]) {
            result.push(c[property]);
          }
          return result;
        }, [])
      );
    }
  }

  <template>
    <CustomWizardCategorySelector
      @categories={{this.categories}}
      @class={{this.fieldClass}}
      @whitelist={{this.field.content}}
      @onChange={{this.updateCategories}}
      @tabindex={{this.field.tabindex}}
      @options={{hash maximum=this.field.limit}}
    />
  </template>
}
