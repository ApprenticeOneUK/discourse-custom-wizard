import { click, fillIn, visit } from "@ember/test-helpers";
import { test } from "qunit";
import {
  acceptance,
  query,
  queryAll,
} from "discourse/tests/helpers/qunit-helpers";
import selectKit from "discourse/tests/helpers/select-kit-helper";
import {
  getCustomFields,
  getSuppliers,
  getUnsubscribedAdminWizards,
  getWizard,
} from "../helpers/admin-wizard";

acceptance("Admin | Custom Fields Unsubscribed", function (needs) {
  needs.user();
  needs.settings({
    custom_wizard_enabled: true,
    available_locales: JSON.stringify([{ name: "English", value: "en" }]),
  });

  needs.pretender((server, helper) => {
    server.get("/admin/wizards/wizard", () => {
      return helper.response(getWizard);
    });
    server.get("/admin/wizards/subscription", () => {
      return helper.response(getUnsubscribedAdminWizards);
    });
    server.get("/admin/wizards/custom-fields", () => {
      return helper.response(getCustomFields);
    });
    server.put("/admin/wizards/custom-fields", () => {
      return helper.response({ success: "OK" });
    });
    server.delete("/admin/wizards/custom-fields/topic_custom_field", () => {
      return helper.response({ success: "OK" });
    });
    server.get("/admin/plugins/subscription-client/suppliers", () => {
      return helper.response(getSuppliers);
    });
  });

  async function selectTypeAndSerializerAndFillInName(
    type,
    serializer,
    name,
    summaryName
  ) {
    const typeDropdown = selectKit(
      `.admin-wizard-container details:has(summary[name="${summaryName}"])`
    );
    await typeDropdown.expand();
    await click(
      `.select-kit-collection li[data-value="${type.toLowerCase()}"]`
    );

    const serializerDropdown = selectKit(
      ".admin-wizard-container details.multi-select"
    );
    await serializerDropdown.expand();
    await click(
      `.select-kit-collection li[data-value="${serializer
        .toLowerCase()
        .replace(/ /g, "_")}"]`
    );

    await fillIn(
      ".admin-wizard-container input",
      name.toLowerCase().replace(/ /g, "_")
    );
  }

  test("Navigate to custom fields tab", async (assert) => {
    await visit("/admin/wizards/custom-fields");
    assert.true(Boolean(query("table")));
    assert.strictEqual(
      queryAll("table tbody tr").length,
      4,
      "Display loaded custom fields"
    );
    assert.true(
      Boolean(
        query(".message-content").innerText.includes(
          "View, create, edit and destroy custom fields"
        )
      ),
      "it displays wizard message"
    );
  });
  test("view available custom fields for unsubscribed plan", async (assert) => {
    await visit("/admin/wizards/custom-fields");
    await click(".admin-wizard-controls .btn-icon-text");
    assert
      .dom(".wizard-subscription-selector")
      .isVisible("custom field class is present");
    assert
      .dom(".wizard-subscription-selector-header")
      .isVisible("custom field type is present");
    assert.dom(".input").isVisible("custom field name is present");
    assert.dom(".multi-select").isVisible("custom field serializer is present");
    assert.dom(".actions").isVisible("custom field action buttons are present");

    const dropdown1 = selectKit(
      '.admin-wizard-container details:has(summary[name="Filter by: Select a class"])'
    );
    await dropdown1.expand();
    let enabledOptions1 = queryAll(
      '.admin-wizard-container details:has(summary[name="Filter by: Select a class"]) ul li:not(.disabled)'
    );
    let disabledOptions1 = queryAll(
      '.admin-wizard-container details:has(summary[name="Filter by: Select a class"]) ul li.disabled'
    );
    assert.strictEqual(
      enabledOptions1.length,
      4,
      "All class options are enabled"
    );
    assert.strictEqual(
      disabledOptions1.length,
      0,
      "No class options are disabled"
    );
    const dropdown2 = selectKit(
      '.admin-wizard-container details:has(summary[name="Filter by: Select a type"])'
    );
    await dropdown2.expand();
    let enabledOptions2 = queryAll(
      '.admin-wizard-container details:has(summary[name="Filter by: Select a type"]) ul li:not(.disabled)'
    );
    let disabledOptions2 = queryAll(
      '.admin-wizard-container details:has(summary[name="Filter by: Select a type"]) ul li.disabled'
    );
    assert.strictEqual(
      enabledOptions2.length,
      4,
      "All type options are enabled"
    );
    assert.strictEqual(
      disabledOptions2.length,
      0,
      "No type options are disabled"
    );
  });
  test("change custom fields for unsubscribed plan", async (assert) => {
    await visit("/admin/wizards/custom-fields");
    await click(".admin-wizard-controls .btn-icon-text");

    const dropdown1 = selectKit(
      '.admin-wizard-container details:has(summary[name="Filter by: Select a class"])'
    );
    await dropdown1.expand();
    await click('.select-kit-collection li[data-value="topic"]');
    const serializerDropdown = selectKit(
      ".admin-wizard-container details.multi-select"
    );
    await serializerDropdown.expand();
    let enabledOptions1 = queryAll(
      ".admin-wizard-container details.multi-select ul li"
    );
    assert.strictEqual(
      enabledOptions1.length,
      2,
      "There are two enabled options in the serializer dropdown for Topic"
    );
    await serializerDropdown.collapse();
    const dropdown2 = selectKit(
      '.admin-wizard-container details:has(summary[name="Filter by: Topic"])'
    );
    await dropdown2.expand();
    await click('.select-kit-collection li[data-value="post"]');
    await serializerDropdown.expand();
    let enabledOptions2 = queryAll(
      ".admin-wizard-container details.multi-select ul li"
    );
    assert.strictEqual(
      enabledOptions2.length,
      1,
      "There is one enabled option in the serializer dropdown for Post"
    );
  });

  test("Create Topic and Post custom fields", async (assert) => {
    await visit("/admin/wizards/custom-fields");
    assert.strictEqual(
      queryAll("table tbody tr").length,
      4,
      "Display loaded custom fields"
    );
    await click(".admin-wizard-controls .btn-icon-text");

    const dropdownTopic = selectKit(
      '.admin-wizard-container details:has(summary[name="Filter by: Select a class"])'
    );
    await dropdownTopic.expand();
    await click('.select-kit-collection li[data-value="topic"]');

    await selectTypeAndSerializerAndFillInName(
      "String",
      "Topic View",
      "Topic Custom Field",
      "Filter by: Select a type"
    );

    await click(".actions .save");
    assert.true(
      Boolean(
        query(
          ".admin-wizard-container tbody tr:first-child td:nth-child(1) label"
        ).innerText.includes("topic")
      ),
      "Topic custom field is displayed"
    );
    assert.true(
      Boolean(
        query(
          ".admin-wizard-container tbody tr:first-child td:nth-child(3) label"
        ).innerText.includes("topic_custom_field")
      ),
      "Topic custom field name is displayed"
    );

    await click(".admin-wizard-controls .btn-icon-text");

    const dropdownPost = selectKit(
      '.admin-wizard-container details:has(summary[name="Filter by: Select a class"])'
    );
    await dropdownPost.expand();
    await click('.select-kit-collection li[data-value="post"]');

    await selectTypeAndSerializerAndFillInName(
      "Boolean",
      "Post",
      "Post Custom Field",
      "Filter by: Select a type"
    );

    await click(".actions .save");
    assert.true(
      Boolean(
        query(
          ".admin-wizard-container tbody tr:first-child td:nth-child(1) label"
        ).innerText.includes("post")
      ),
      "Post custom field is displayed"
    );
    assert.true(
      Boolean(
        query(
          ".admin-wizard-container tbody tr:first-child td:nth-child(3) label"
        ).innerText.includes("post_custom_field")
      ),
      "Post custom field name is displayed"
    );
    assert.strictEqual(
      queryAll("table tbody tr").length,
      6,
      "Display added custom fields"
    );
  });
  test("Update Topic custom field", async (assert) => {
    await visit("/admin/wizards/custom-fields");
    await click(".admin-wizard-controls .btn-icon-text");
    const dropdownTopic = selectKit(
      '.admin-wizard-container details:has(summary[name="Filter by: Select a class"])'
    );
    await dropdownTopic.expand();
    await click('.select-kit-collection li[data-value="topic"]');
    await selectTypeAndSerializerAndFillInName(
      "String",
      "Topic View",
      "Topic Custom Field",
      "Filter by: Select a type"
    );
    await click(".actions .save");
    await click(".admin-wizard-container tbody tr:first-child button");
    await selectTypeAndSerializerAndFillInName(
      "Boolean",
      "Topic List Item",
      "Updated Topic Custom Field",
      "Filter by: String"
    );
    await click(".admin-wizard-container tbody tr:first-child .save");
    assert.true(
      Boolean(
        query(
          ".admin-wizard-container tbody tr:first-child td:nth-child(1) label"
        ).innerText.includes("topic")
      ),
      "Topic custom field is displayed"
    );
    assert.true(
      Boolean(
        query(
          ".admin-wizard-container tbody tr:first-child td:nth-child(2) label"
        ).innerText.includes("boolean")
      ),
      "Updated Type is displayed"
    );
    assert.true(
      Boolean(
        query(
          ".admin-wizard-container tbody tr:first-child td:nth-child(3) label"
        ).innerText.includes("updated_topic_custom_field")
      ),
      "Updated Topic custom field name is displayed"
    );
    assert.true(
      Boolean(
        query(
          ".admin-wizard-container tbody tr:first-child td:nth-child(4)"
        ).innerText.includes("topic_view")
      ),
      "Original Serializer is displayed"
    );
    assert.true(
      Boolean(
        query(
          ".admin-wizard-container tbody tr:first-child td:nth-child(4)"
        ).innerText.includes("topic_list_item")
      ),
      "Updated Serializer is displayed"
    );
  });
  test("Delete Topic custom field", async (assert) => {
    await visit("/admin/wizards/custom-fields");
    assert.strictEqual(
      queryAll("table tbody tr").length,
      4,
      "Display loaded custom fields"
    );
    await click(".admin-wizard-controls .btn-icon-text");

    const dropdownTopic = selectKit(
      '.admin-wizard-container details:has(summary[name="Filter by: Select a class"])'
    );
    await dropdownTopic.expand();
    await click('.select-kit-collection li[data-value="topic"]');
    await selectTypeAndSerializerAndFillInName(
      "String",
      "Topic View",
      "Topic Custom Field",
      "Filter by: Select a type"
    );
    await click(".actions .save");
    assert.strictEqual(
      queryAll("table tbody tr").length,
      5,
      "Display added custom fields"
    );
    await click(".admin-wizard-container tbody tr:first-child button");
    await click(".actions .destroy");
    assert.strictEqual(
      queryAll("table tbody tr").length,
      4,
      "Display custom fields without deleted fields"
    );
  });
});
