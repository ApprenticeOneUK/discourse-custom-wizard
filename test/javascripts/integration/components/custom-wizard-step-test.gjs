import EmberObject from "@ember/object";
import { click, render, settled } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import CustomWizardStep from "discourse/plugins/discourse-custom-wizard/discourse/components/custom-wizard-step";

module("Integration | Component | custom-wizard-step", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.step = EmberObject.create({
      id: "step_1",
      index: 0,
      displayIndex: 1,
      title: "",
      translatedTitle: "",
      description: "",
      translatedDescription: "",
      fields: [],
      final: false,
      message: null,
    });
    this.wizard = EmberObject.create({
      completed: false,
      required: false,
      totalSteps: 2,
      skip() {},
    });
    this.appEvents = { on() {} };
    this.noop = () => {};
  });

  test("propagates messages set on the current step", async function (assert) {
    const messages = [];
    this.showMessage = (message) => messages.push(message);

    await render(
      <template>
        <CustomWizardStep
          @appEvents={{this.appEvents}}
          @step={{this.step}}
          @wizard={{this.wizard}}
          @goNext={{this.noop}}
          @goBack={{this.noop}}
          @onShowMessage={{this.showMessage}}
        />
      </template>
    );

    const message = { state: "error", text: "The step could not be saved" };
    this.step.set("message", message);
    await settled();

    assert.deepEqual(messages, [message]);
  });

  test("action links prevent native navigation", async function (assert) {
    let skipCount = 0;
    let backCount = 0;
    this.wizard.set("skip", () => skipCount++);
    this.goBack = () => backCount++;

    await render(
      <template>
        <CustomWizardStep
          @appEvents={{this.appEvents}}
          @step={{this.step}}
          @wizard={{this.wizard}}
          @goNext={{this.noop}}
          @goBack={{this.goBack}}
          @onShowMessage={{this.noop}}
        />
      </template>
    );

    let defaultPrevented = false;
    document
      .querySelector(".action-link.quit")
      .addEventListener("click", (e) => {
        defaultPrevented = e.defaultPrevented;
      });
    await click(".action-link.quit");

    assert.true(defaultPrevented, "the quit link prevents navigation");
    assert.strictEqual(skipCount, 1, "the quit action still runs");

    this.step.set("index", 1);
    await settled();

    defaultPrevented = false;
    document
      .querySelector(".action-link.back")
      .addEventListener("click", (e) => {
        defaultPrevented = e.defaultPrevented;
      });
    await click(".action-link.back");

    assert.true(defaultPrevented, "the back link prevents navigation");
    assert.strictEqual(backCount, 1, "the back action still runs");
  });
});
