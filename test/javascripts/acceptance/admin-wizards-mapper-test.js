import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import {
  getUnsubscribedAdminWizards,
  getWizard,
} from "../helpers/admin-wizard";

function assignment(output, outputType) {
  return [
    {
      type: "assignment",
      output,
      output_type: outputType,
      output_connector: "set",
    },
  ];
}

const mappedWizard = {
  id: "mapped_wizard",
  name: "Mapped wizard",
  save_submissions: true,
  permitted: assignment([13], "group"),
  steps: [
    {
      id: "step_1",
      title: "step 1",
      fields: [{ id: "step_1_field_1", label: "label field", type: "text" }],
    },
  ],
  actions: [
    {
      id: "action_1",
      run_after: "wizard_completion",
      type: "create_topic",
      title: assignment("Topic title", "text"),
      category: assignment([30], "category"),
      tags: assignment(["gazelle"], "tag"),
      visible: [
        {
          type: "conditional",
          output: "Result text",
          output_type: "text",
          output_connector: "then",
          pairs: [
            {
              index: 0,
              key: "step_1_field_1",
              key_type: "wizard_field",
              value: "Some value",
              value_type: "text",
              connector: "equal",
            },
          ],
        },
      ],
    },
  ],
};

acceptance("Admin | Custom Wizard | Mapped settings", function (needs) {
  let savedWizard = null;

  needs.user();
  needs.settings({
    custom_wizard_enabled: true,
    available_locales: JSON.stringify([{ name: "English", value: "en" }]),
  });

  needs.hooks.beforeEach(() => {
    savedWizard = null;
  });

  needs.pretender((server, helper) => {
    const responses = {
      "/admin/wizards/wizard": getWizard,
      "/admin/wizards/subscription": getUnsubscribedAdminWizards,
      "/admin/config/user_fields": { user_fields: [] },
      "/admin/wizards/wizard/mapped_wizard": mappedWizard,
    };

    Object.entries(responses).forEach(([url, response]) => {
      server.get(url, () => helper.response(response));
    });

    server.put("/admin/wizards/wizard/mapped_wizard", (request) => {
      savedWizard = JSON.parse(request.requestBody).wizard;
      return helper.response({ success: "OK", wizard_id: "mapped_wizard" });
    });
  });

  test("keeps mapped settings when a wizard is saved without changes", async function (assert) {
    await visit("/admin/wizards/wizard/mapped_wizard");
    await click(".admin-wizard-buttons button");

    assert.deepEqual(
      savedWizard.permitted,
      mappedWizard.permitted,
      "the permitted groups are unchanged"
    );

    for (const property of ["title", "category", "tags", "visible"]) {
      assert.deepEqual(
        savedWizard.actions[0][property],
        mappedWizard.actions[0][property],
        `the action ${property} is unchanged`
      );
    }
  });
});
