import { click, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import WizardTableField from "discourse/plugins/discourse-custom-wizard/discourse/components/wizard-table-field";

module("Integration | Component | wizard-table-field", function (hooks) {
  setupRenderingTest(hooks);

  test("expands long text without following the action link", async function (assert) {
    const value = {
      type: "long_text",
      value: "Long submission text",
    };

    await render(
      <template><WizardTableField @field="answer" @value={{value}} /></template>
    );

    let defaultPrevented = false;
    document
      .querySelector(".wizard-table-long-text a")
      .addEventListener("click", (event) => {
        defaultPrevented = event.defaultPrevented;
      });

    await click(".wizard-table-long-text a");

    assert.true(defaultPrevented);
    assert.dom(".wizard-table-long-text-content").hasClass("text-expanded");
  });
});
