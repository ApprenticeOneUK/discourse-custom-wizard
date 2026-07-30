import { computed } from "@ember/object";
import { makeArray } from "discourse/lib/helpers";
import ComboBox from "discourse/select-kit/components/combo-box";

export default ComboBox.extend({
  content: computed("groups.[]", "field.content.[]", function () {
    const whitelist = makeArray(this.field.content);
    return this.groups
      .filter((group) => {
        return !whitelist.length || whitelist.indexOf(group.id) > -1;
      })
      .map((g) => {
        return {
          id: g.id,
          name: g.full_name ? g.full_name : g.name,
        };
      });
  }),
});
