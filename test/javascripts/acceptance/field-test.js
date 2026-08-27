import { getOwner } from "@ember/owner";
import { click, fillIn, triggerKeyEvent, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import {
  acceptance,
  count,
  query,
} from "discourse/tests/helpers/qunit-helpers";
import selectKit from "discourse/tests/helpers/select-kit-helper";
import tagsJson from "../fixtures/tags";
import usersJson from "../fixtures/users";
import { allFieldsWizard } from "../helpers/wizard";

acceptance("Field | Fields", function (needs) {
  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => helper.response(allFieldsWizard));
    server.get("/custom-wizard/tags/search", () =>
      helper.response({ results: tagsJson["tags"] })
    );
    server.get("/u/search/users", () => helper.response(usersJson));

    server.post(
      "/uploads.json",
      () => {
        return helper.response({
          extension: "jpeg",
          filesize: 126177,
          height: 800,
          human_filesize: "123 KB",
          id: 202,
          original_filename: "avatar.PNG.jpg",
          retain_hours: null,
          short_path: "/uploads/short-url/yoj8pf9DdIeHRRULyw7i57GAYdz.jpeg",
          short_url: "upload://yoj8pf9DdIeHRRULyw7i57GAYdz.jpeg",
          thumbnail_height: 320,
          thumbnail_width: 690,
          url: "/images/discourse-logo-sketch-small.png",
          width: 1920,
        });
      },
      500 // this delay is important to slow down the uploads a bit so we can let elements of the interface update
    );
  });

  test("Text", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-field.text-field input.wizard-focusable").exists();
  });

  test("Textarea", async function (assert) {
    await visit("/w/wizard");
    assert
      .dom(".wizard-field.textarea-field textarea.wizard-focusable")
      .isVisible();
  });

  test("Composer", async function (assert) {
    await visit("/w/wizard");
    assert
      .dom(".wizard-field.composer-field .wizard-field-composer textarea")
      .isVisible();
    assert
      .dom(".wizard-field.composer-field .d-editor-button-bar button")
      .exists();
    assert.dom(".wizard-btn.toggle-preview").isVisible();

    await fillIn(
      ".wizard-field.composer-field .wizard-field-composer textarea",
      "Input in composer"
    );
    await click(".wizard-btn.toggle-preview");
    assert.strictEqual(
      query(
        ".wizard-field.composer-field .wizard-field-composer .d-editor-preview-wrapper p"
      ).textContent.trim(),
      "Input in composer"
    );
  });

  test("Composer - Hyperlink", async function (assert) {
    await visit("/w/wizard");
    assert
      .dom(".wizard-field.composer-field .wizard-field-composer textarea")
      .isVisible();
    assert
      .dom(".wizard-field.composer-field .d-editor-button-bar button")
      .exists();
    assert.dom(".wizard-btn.toggle-preview").isVisible();
    await fillIn(
      ".wizard-field.composer-field .wizard-field-composer textarea",
      "This is a link to "
    );
    assert
      .dom(".d-modal.upsert-hyperlink-modal")
      .doesNotExist("no hyperlink modal by default");
    await click(
      ".wizard-field.composer-field .wizard-field-composer  .d-editor button.link"
    );
    assert
      .dom(".d-modal.upsert-hyperlink-modal")
      .exists("hyperlink modal visible");

    await fillIn(".d-modal__body.insert-link .inputs .link-url", "google.com");
    await fillIn(".d-modal__body.insert-link .inputs .link-text", "Google");
    await click(".d-modal__footer button.btn-primary");

    assert.strictEqual(
      query(".wizard-field.composer-field .wizard-field-composer textarea")
        .value,
      "This is a link to [Google](https://google.com)",
      "adds link with url and text, prepends 'https://'"
    );

    assert
      .dom(
        ".wizard-field.composer-field .wizard-field-composer .insert-link.modal-body"
      )
      .doesNotExist("modal dismissed after submitting link");

    await fillIn(
      ".wizard-field.composer-field .wizard-field-composer textarea",
      "Reset textarea contents."
    );

    await click(
      ".wizard-field.composer-field .wizard-field-composer .d-editor button.link"
    );
    await fillIn(".d-modal__body.insert-link .inputs .link-url", "google.com");
    await fillIn(".d-modal__body.insert-link .inputs .link-text", "Google");
    await click(".d-modal__footer button.btn-transparent");

    assert.strictEqual(
      query(".wizard-field.composer-field .wizard-field-composer textarea")
        .value,
      "Reset textarea contents.",
      "does not insert anything after cancelling"
    );

    assert
      .dom(".insert-link.modal-body")
      .doesNotExist("modal dismissed after cancelling");
  });

  test("Text Only", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-field.text-only-field label.field-label").isVisible();
  });

  test("Time", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-field.time-field .select-kit").isVisible();
    await click(".wizard-field.time-field .select-kit .select-kit-header");
    assert.dom(".wizard-field.time-field .select-kit-collection").isVisible();
  });

  test("Number", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-field.number-field input[type='number']").isVisible();
  });

  test("Checkbox", async function (assert) {
    await visit("/w/wizard");
    assert
      .dom(".wizard-field.checkbox-field input[type='checkbox']")
      .isVisible();
  });

  test("Url", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-field.url-field input[type='text']").isVisible();
  });

  test("Dropdown", async function (assert) {
    await visit("/w/wizard");
    assert
      .dom(".wizard-field.dropdown-field .single-select-header")
      .isVisible();
    await click(".wizard-field.dropdown-field .select-kit-header");
    assert.strictEqual(
      count(".wizard-field.dropdown-field .select-kit-collection li"),
      3
    );
  });

  test("Tag", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-field.tag-field .multi-select-header").isVisible();
    await click(".wizard-field.tag-field .select-kit-header");
    assert.strictEqual(
      count(".wizard-field.tag-field .select-kit-collection li"),
      2
    );
  });

  test("Category", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-field.category-field .multi-select-header").isVisible();
    await click(".wizard-field.category-field .select-kit-header");
    assert
      .dom(
        ".wizard-field.category-field .select-kit-collection .select-kit-row"
      )
      .exists();
  });

  test("Topic", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-field.topic-field .multi-select-header").isVisible();
    await click(".wizard-field.topic-field .select-kit-header");
    assert
      .dom(".wizard-field.topic-field .topic-selector .select-kit-filter")
      .exists();
  });

  test("Group", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-field.group-field .single-select-header").isVisible();
    await click(".wizard-field.group-field .select-kit-header");
    assert.strictEqual(
      count(".wizard-field.group-field .select-kit-collection li"),
      getOwner(this).lookup("service:site").groups.length,
      "all site groups are listed"
    );
  });

  test("User", async function (assert) {
    await visit("/w/wizard");
    await click(".wizard-field.user-selector-field .d-multi-select-trigger");
    await fillIn(".d-multi-select__search-input", "a");
    await triggerKeyEvent(
      ".d-multi-select__search-input",
      "keyup",
      "a".charCodeAt(0)
    );

    assert
      .dom(".wizard-field.user-selector-field .d-multi-select-trigger")
      .isVisible();
    // TODO: add assertion for ac results. autocomplete does not appear in time.
  });
});

acceptance("Field | Required validation", function (needs) {
  const requiredFieldsWizard = cloneJSON(allFieldsWizard);
  const sourceFields = requiredFieldsWizard.steps[0].fields;
  const dropdown = sourceFields.find((field) => field.type === "dropdown");
  const checkbox = sourceFields.find((field) => field.type === "checkbox");
  const textarea = sourceFields.find((field) => field.type === "textarea");

  requiredFieldsWizard.steps[0].fields = [
    {
      ...dropdown,
      id: "required_dropdown_1",
      required: true,
      value: null,
    },
    {
      ...dropdown,
      id: "required_dropdown_2",
      required: true,
      value: null,
    },
    {
      ...checkbox,
      id: "required_checkbox",
      required: true,
      value: false,
    },
    {
      ...textarea,
      id: "required_text",
      required: true,
      value: "",
    },
  ];

  needs.settings({
    wizard_required_field_error_message: "Complete this custom field.",
    wizard_required_dropdown_error_message: "Select a custom option.",
    wizard_required_checkbox_error_message: "Tick this custom box.",
  });

  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => helper.response(requiredFieldsWizard));
  });

  test("shows configurable messages for every unanswered required field", async function (assert) {
    await visit("/w/wizard");
    await click(".wizard-btn.next");

    assert.strictEqual(
      count(".field-error-description[role='alert']"),
      4,
      "every required field displays an accessible error"
    );
    assert
      .dom(".required_dropdown_1 .field-error-description")
      .hasText("Select a custom option.");
    assert
      .dom(".required_dropdown_2 .field-error-description")
      .hasText("Select a custom option.");
    assert
      .dom(".required_checkbox .field-error-description")
      .hasText("Tick this custom box.");
    assert
      .dom(".required_text .field-error-description")
      .hasText("Complete this custom field.");

    const dropdownSelect = selectKit(".field-required-dropdown-1");
    await dropdownSelect.expand();
    await dropdownSelect.selectRowByValue("one");

    assert
      .dom(".required_dropdown_1 .field-error-description")
      .doesNotExist("the error clears as soon as the field is completed");
  });
});

acceptance("Field | Tag search request", function (needs) {
  let capturedParams;

  needs.pretender((server, helper) => {
    const baseTagField = allFieldsWizard.steps[0].fields.find(
      (field) => field.type === "tag"
    );
    const tagWizard = {
      ...allFieldsWizard,
      steps: [
        {
          ...allFieldsWizard.steps[0],
          fields: [
            {
              ...baseTagField,
              tag_groups: ["colours", "sizes"],
              content: ["red", "blue"],
            },
          ],
        },
      ],
    };

    server.get("/w/wizard.json", () => helper.response(tagWizard));
    server.get("/custom-wizard/tags/search", (request) => {
      capturedParams = request.queryParams;
      return helper.response({ results: tagsJson["tags"] });
    });
  });

  test("sends the field's tag groups and content allow-list to the endpoint", async function (assert) {
    await visit("/w/wizard");
    await click(".wizard-field.tag-field .select-kit-header");

    assert.strictEqual(
      capturedParams.tag_groups,
      "colours,sizes",
      "joins the configured tag groups"
    );
    assert.deepEqual(
      capturedParams.content,
      ["red", "blue"],
      "sends the content allow-list tag names"
    );
  });
});

acceptance("Field | Tag submission", function (needs) {
  const [, secondTag] = tagsJson.tags;
  let submittedFields;

  needs.hooks.beforeEach(() => {
    submittedFields = null;
  });

  needs.pretender((server, helper) => {
    const tagField = allFieldsWizard.steps[0].fields.find(
      (field) => field.type === "tag"
    );
    const tagWizard = {
      ...allFieldsWizard,
      steps: [
        { ...allFieldsWizard.steps[0], fields: [tagField] },
        { id: "step_2", index: 1, title: "step 2", fields: [] },
      ],
    };

    server.get("/w/wizard.json", () => helper.response(tagWizard));
    server.get("/custom-wizard/tags/search", () =>
      helper.response({ results: tagsJson.tags })
    );
    server.put("/w/wizard/steps/step_1", (request) => {
      submittedFields = JSON.parse(request.requestBody).fields;
      return helper.response({
        final: false,
        next_step_id: "step_2",
        wizard: tagWizard,
      });
    });
  });

  test("submits the selected tag names", async function (assert) {
    await visit("/w/wizard");

    const tagChooser = selectKit(".wizard-field.tag-field .tag-chooser");
    await tagChooser.expand();
    await tagChooser.selectRowByValue(secondTag.id);
    await click(".wizard-step-footer .wizard-btn.next");

    assert.deepEqual(
      submittedFields.step_3_field_2,
      [secondTag.name],
      "the tag field value is submitted as tag names"
    );
  });
});
