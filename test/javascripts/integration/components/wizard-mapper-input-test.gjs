import EmberObject from "@ember/object";
import { trackedArray } from "@ember/reactive/collections";
import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import selectKit from "discourse/tests/helpers/select-kit-helper";
import WizardMapperInput from "discourse/plugins/discourse-custom-wizard/discourse/components/wizard-mapper-input";

module("Integration | Component | wizard-mapper-input", function (hooks) {
  setupRenderingTest(hooks);

  test("sets up mapper state when the input type changes", async function (assert) {
    const input = EmberObject.create({
      type: "assignment",
      pairs: trackedArray(),
      output: null,
      output_type: "text",
      output_connector: "set",
    });
    const options = {
      inputTypes: "assignment,conditional",
      textSelection: true,
    };
    const noop = () => {};

    await render(
      <template>
        <WizardMapperInput
          @input={{input}}
          @options={{options}}
          @remove={{noop}}
          @onUpdate={{noop}}
        />
      </template>
    );

    input.set("output", "stale output");

    const inputType = selectKit(
      ".mapper-input > .mapper-connector .select-kit"
    );
    await inputType.expand();
    await inputType.selectRowByValue("conditional");

    assert.strictEqual(input.type, "conditional");
    assert.strictEqual(input.output, null, "stale output is cleared");
    assert.strictEqual(input.pairs.length, 1, "a required pair is added");
  });
});
