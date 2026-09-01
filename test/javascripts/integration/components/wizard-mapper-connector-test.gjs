import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import WizardMapperConnector from "discourse/plugins/discourse-custom-wizard/discourse/components/wizard-mapper-connector";

module("Integration | Component | wizard-mapper-connector", function (hooks) {
  setupRenderingTest(hooks);

  test("renders a fixed connector without a connector list", async function (assert) {
    await render(
      <template>
        <WizardMapperConnector @connector="or" @connectorType="input" />
      </template>
    );

    assert
      .dom(".mapper-connector.single .connector-single")
      .exists("renders the fixed connector instead of throwing");
    assert
      .dom(".mapper-connector .select-kit")
      .doesNotExist("does not render a selector without connector options");
  });
});
