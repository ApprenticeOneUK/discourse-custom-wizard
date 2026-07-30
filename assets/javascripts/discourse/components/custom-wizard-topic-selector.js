import { action } from "@ember/object";
import { isEmpty } from "@ember/utils";
import { classNames } from "@ember-decorators/component";
import { makeArray } from "discourse/lib/helpers";
import { searchForTerm } from "discourse/lib/search";
import MultiSelectComponent from "discourse/select-kit/components/multi-select";
import { selectKitOptions } from "discourse/select-kit/components/select-kit";

@classNames("topic-selector", "wizard-topic-selector")
@selectKitOptions({
  clearable: true,
  filterable: true,
  filterPlaceholder: "choose_topic.title.placeholder",
  allowAny: false,
})
export default class CustomWizardTopicSelector extends MultiSelectComponent {
  topics = null;
  value = [];
  content = [];
  nameProperty = "fancy_title";
  labelProperty = "title";
  titleProperty = "title";

  didReceiveAttrs() {
    if (this.topics && !this.selectKit.hasSelection) {
      const values = makeArray(this.topics.map((t) => t.id));
      const content = makeArray(this.topics);
      this.selectKit.change(values, content);
    }
    super.didReceiveAttrs(...arguments);
  }

  modifyComponentForRow() {
    return "topic-row";
  }

  search(filter) {
    if (isEmpty(filter)) {
      return [];
    }

    const searchParams = {};
    searchParams.typeFilter = "topic";
    searchParams.restrictToArchetype = "regular";
    searchParams.searchForId = true;

    if (this.category) {
      searchParams.searchContext = {
        type: "category",
        id: this.category,
      };
    }

    return searchForTerm(filter, searchParams).then((results) => {
      if (results?.posts?.length > 0) {
        return results.posts.mapBy("topic");
      }
    });
  }

  @action
  onChange(value, items) {
    const content = items.map((topic) => {
      const attrs = {
        id: topic.id,
        title: topic.title,
        fancy_title: topic.fancy_title,
        url: topic.url,
      };
      if (topic.featured_link) {
        attrs.featured_link = topic.featured_link;
      }
      return attrs;
    });
    this.setProperties({ value, content });
    this.onChangeCallback(value, content);
  }
}
