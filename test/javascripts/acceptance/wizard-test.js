import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import sinon from "sinon";
import DiscourseURL from "discourse/lib/url";
import pretender, { response } from "discourse/tests/helpers/create-pretender";
import {
  acceptance,
  count,
  query,
} from "discourse/tests/helpers/qunit-helpers";
import { i18n } from "discourse-i18n";
import {
  wizard,
  wizardCompleted,
  wizardGuest,
  wizardNotPermitted,
  wizardNoUser,
  wizardResumeOnRevisit,
} from "../helpers/wizard";

acceptance("Wizard | Not logged in", function (needs) {
  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => helper.response(wizardNoUser));
  });

  test("Requires login", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-no-access.requires-login").exists();
  });

  test("Requires login if a step path is used", async function (assert) {
    await visit("/w/wizard/steps/1");
    assert.dom(".wizard-no-access.requires-login").exists();
  });
});

acceptance("Wizard | Not permitted", function (needs) {
  needs.user();
  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => helper.response(wizardNotPermitted));
  });

  test("Wizard no access not permitted", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-no-access.not-permitted").exists();
  });
});

acceptance("Wizard | Completed", function (needs) {
  needs.user();
  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => helper.response(wizardCompleted));
  });

  test("Wizard no access completed", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-no-access.completed").exists();
  });
});

acceptance("Wizard | Redirect", function (needs) {
  needs.user({
    redirect_to_wizard: "wizard",
  });
  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => {
      return helper.response(wizard);
    });
  });

  test("Redirect to pending Wizard", async function (assert) {
    sinon.stub(DiscourseURL, "routeTo");
    await visit("/latest");
    assert.true(
      Boolean(DiscourseURL.routeTo.calledWith("/w/wizard")),
      "pending wizard routing works"
    );
  });

  test("Don't redirect to pending Wizard when ingore redirect param is supplied", async function (assert) {
    sinon.stub(DiscourseURL, "routeTo");
    await visit("/latest?ignore_redirect=1");
    assert.false(
      Boolean(DiscourseURL.routeTo.calledWith("/w/wizard")),
      "pending wizard routing blocked"
    );
  });
});

acceptance("Wizard | Wizard", function (needs) {
  needs.user();
  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => {
      return helper.response(wizard);
    });
  });

  test("Starts", async function (assert) {
    await visit("/w/wizard");
    assert.true(Boolean(query(".wizard-column")), true);
  });

  test("Applies the wizard body class", async function (assert) {
    await visit("/w/wizard");
    assert.dom(document.body).hasClass("custom-wizard");
  });

  test("Applies the body background color", async function (assert) {
    await visit("/w/wizard");
    assert.true(Boolean(document.body.style.background));
  });

  test("Renders the wizard form", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-column-contents .wizard-step").exists();
    assert.dom(".wizard-footer img").exists();
  });

  test("Renders the first step", async function (assert) {
    await visit("/w/wizard");
    assert.strictEqual(
      query(".wizard-step-title p").textContent.trim(),
      "Text"
    );
    assert.strictEqual(
      query(".wizard-step-description p").textContent.trim(),
      "Text inputs!"
    );
    assert.strictEqual(
      query(".wizard-step-description p").textContent.trim(),
      "Text inputs!"
    );
    assert.strictEqual(count(".wizard-step-form .wizard-field"), 6);
    assert.dom(".wizard-step-footer .wizard-progress").exists();
    assert.dom(".wizard-step-footer .wizard-buttons").exists();
  });

  test("Removes the wizard body class when navigating away", async function (assert) {
    await visit("/");
    assert.dom(document.body).doesNotHaveClass("custom-wizard");
  });
});

acceptance("Wizard | Guest access", function (needs) {
  needs.pretender((server, helper) => {
    server.get("/w/wizard.json", () => helper.response(wizardGuest));
  });

  test("Does not require login", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-no-access.requires-login").doesNotExist();
  });

  test("Starts", async function (assert) {
    await visit("/w/wizard");
    assert.true(Boolean(query(".wizard-column")), true);
  });

  test("Applies the wizard body class", async function (assert) {
    await visit("/w/wizard");
    assert.dom(document.body).hasClass("custom-wizard");
  });

  test("Applies the body background color", async function (assert) {
    await visit("/w/wizard");
    assert.true(Boolean(document.body.style.background));
  });

  test("Renders the wizard form", async function (assert) {
    await visit("/w/wizard");
    assert.dom(".wizard-column-contents .wizard-step").exists();
    assert.dom(".wizard-footer img").exists();
  });

  test("Renders the first step", async function (assert) {
    await visit("/w/wizard");
    assert.strictEqual(
      query(".wizard-step-title p").textContent.trim(),
      "Text"
    );
    assert.strictEqual(
      query(".wizard-step-description p").textContent.trim(),
      "Text inputs!"
    );
    assert.strictEqual(
      query(".wizard-step-description p").textContent.trim(),
      "Text inputs!"
    );
    assert.strictEqual(count(".wizard-step-form .wizard-field"), 6);
    assert.dom(".wizard-step-footer .wizard-progress").exists();
    assert.dom(".wizard-step-footer .wizard-buttons").exists();
  });

  test("Removes the wizard body class when navigating away", async function (assert) {
    await visit("/");
    assert.dom(document.body).doesNotHaveClass("custom-wizard");
  });
});

acceptance("Wizard | Resume on revisit", function (needs) {
  needs.user();

  test("Shows dialog", async function (assert) {
    pretender.get("/w/wizard.json", () => {
      return response(wizardResumeOnRevisit);
    });

    await visit("/w/wizard");

    assert.dom(".dialog-content").isVisible();
    assert.strictEqual(
      query(".dialog-header h3").textContent.trim(),
      i18n("wizard.incomplete_submission.title", {
        date: moment(wizardResumeOnRevisit.submission_last_updated_at).format(
          "MMMM Do YYYY"
        ),
      })
    );
  });

  test("Resumes when resumed", async function (assert) {
    pretender.get("/w/wizard.json", () => {
      return response(wizardResumeOnRevisit);
    });
    await visit("/w/wizard");
    await click(".dialog-footer .btn-primary");
    assert.dom(".dialog-content").doesNotExist();
  });

  test("Restarts when restarted", async function (assert) {
    sinon.stub(DiscourseURL, "redirectTo");
    let skips = 0;
    pretender.get("/w/wizard.json", () => {
      return response(wizardResumeOnRevisit);
    });
    pretender.put("/w/wizard/skip", () => {
      skips++;
      return response({});
    });
    await visit("/w/wizard");
    await click(".dialog-footer .btn-default");
    assert.strictEqual(skips, 1);
    assert.true(
      Boolean(DiscourseURL.redirectTo.calledWith("/w/wizard")),
      "resuming wizard works"
    );
  });
});
