import EmberObject from "@ember/object";
import { trackedArray } from "@ember/reactive/collections";
import { click, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import selectKit from "discourse/tests/helpers/select-kit-helper";
import WizardMapperInput from "discourse/plugins/discourse-custom-wizard/discourse/components/wizard-mapper-input";
import CustomWizardAdmin from "discourse/plugins/discourse-custom-wizard/discourse/models/custom-wizard-admin";

const noop = () => {};

function assignmentInput(props = {}) {
  return EmberObject.create({
    type: "assignment",
    output: "Saved output",
    output_type: "text",
    output_connector: "set",
    ...props,
  });
}

async function renderInput(input, options) {
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
}

module("Integration | Component | wizard-mapper-input", function (hooks) {
  setupRenderingTest(hooks);

  test("sets up mapper state when the input type changes", async function (assert) {
    const input = assignmentInput({ pairs: trackedArray() });

    await renderInput(input, {
      inputTypes: "assignment,conditional",
      textSelection: true,
    });

    const inputType = selectKit(
      ".mapper-input > .mapper-connector .select-kit"
    );
    await inputType.expand();
    await inputType.selectRowByValue("conditional");

    assert.strictEqual(input.type, "conditional");
    assert.strictEqual(input.output, null, "the stale output is cleared");
    assert.strictEqual(input.pairs.length, 1, "a required pair is added");
  });

  test("keeps a saved output on initial render", async function (assert) {
    const input = assignmentInput();

    await renderInput(input, {
      inputTypes: "assignment,conditional",
      textSelection: true,
    });

    assert.strictEqual(
      input.output,
      "Saved output",
      "the saved output is not cleared"
    );
    assert
      .dom(".mapper-input .output .mapper-selector input")
      .hasValue("Saved output", "the saved output is displayed");
  });

  test("keeps a saved output type on initial render", async function (assert) {
    const input = assignmentInput();

    await renderInput(input, {
      inputTypes: "assignment,conditional",
      textSelection: "output",
      tagSelection: "output",
      outputDefaultSelection: "tag",
    });

    assert.strictEqual(
      input.output_type,
      "text",
      "the saved output type is not reset to the default"
    );
    assert
      .dom(".mapper-input .output .mapper-selector")
      .hasClass("text", "the saved output type is displayed");
  });

  test("renders pairs added to and removed from an input built from wizard json", async function (assert) {
    const wizard = CustomWizardAdmin.create({
      id: "test_wizard",
      steps: [],
      actions: [
        {
          id: "action_1",
          type: "create_topic",
          title: [
            {
              type: "conditional",
              output: "Saved output",
              output_type: "text",
              output_connector: "then",
              pairs: [
                {
                  index: 0,
                  key: "Saved key",
                  key_type: "text",
                  value: "Saved value",
                  value_type: "text",
                  connector: "equal",
                },
              ],
            },
          ],
        },
      ],
    });

    await renderInput(wizard.actions[0].title[0], {
      inputTypes: "conditional",
      textSelection: true,
    });

    assert.dom(".mapper-pair").exists({ count: 1 }, "the saved pair renders");

    await click(".add-pair");

    assert.dom(".mapper-pair").exists({ count: 2 }, "the added pair renders");

    await click(".mapper-pair:nth-of-type(2) .remove-pair");

    assert
      .dom(".mapper-pair")
      .exists({ count: 1 }, "the removed pair no longer renders");
  });
});
