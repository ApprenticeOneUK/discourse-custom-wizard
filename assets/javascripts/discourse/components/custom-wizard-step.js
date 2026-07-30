/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { action, computed } from "@ember/object";
import { schedule } from "@ember/runloop";
import { trustHTML } from "@ember/template";
import { classNameBindings } from "@ember-decorators/component";
import { observes } from "discourse/lib/decorators";
import getUrl from "discourse/lib/get-url";
import discourseLater from "discourse/lib/later";
import { cook } from "discourse/lib/text";
import CustomWizard, {
  updateCachedWizard,
} from "discourse/plugins/discourse-custom-wizard/discourse/models/custom-wizard";
import { wizardComposerEdtiorEventPrefix } from "./custom-wizard-composer-editor";

const uploadStartedEventKeys = ["upload-started"];
const uploadEndedEventKeys = [
  "upload-success",
  "upload-error",
  "upload-cancelled",
  "uploads-cancelled",
  "uploads-aborted",
  "all-uploads-complete",
];

@classNameBindings(":wizard-step", "step.id")
export default class CustomWizardStep extends Component {
  saving = null;

  init() {
    super.init(...arguments);
    this.set("stylingDropdown", {});
  }

  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);

    cook(this.step.translatedTitle).then((cookedTitle) => {
      this.set("cookedTitle", cookedTitle);
    });
    cook(this.step.translatedDescription).then((cookedDescription) => {
      this.set("cookedDescription", cookedDescription);
    });

    uploadStartedEventKeys.forEach((key) => {
      this.appEvents.on(`${wizardComposerEdtiorEventPrefix}:${key}`, () => {
        this.set("uploading", true);
      });
    });
    uploadEndedEventKeys.forEach((key) => {
      this.appEvents.on(`${wizardComposerEdtiorEventPrefix}:${key}`, () => {
        this.set("uploading", false);
      });
    });
  }

  didInsertElement() {
    super.didInsertElement(...arguments);
    this.autoFocus();
  }

  @computed("step.index", "wizard.required")
  get showQuitButton() {
    return this.step.index === 0 && !this.wizard.required;
  }

  @computed("step.final")
  get showNextButton() {
    return !this.step.final;
  }

  @computed("step.final")
  get showDoneButton() {
    return this.step.final;
  }

  @computed("saving", "uploading")
  get btnsDisabled() {
    return this.saving || this.uploading;
  }

  @computed(
    "step.index",
    "step.displayIndex",
    "wizard.totalSteps",
    "wizard.completed"
  )
  get showFinishButton() {
    return (
      this.step.index !== 0 &&
      this.step.displayIndex !== this.wizard.totalSteps &&
      this.wizard.completed
    );
  }

  @computed("step.index")
  get showBackButton() {
    return this.step.index > 0;
  }

  @computed("step.banner")
  get bannerImage() {
    if (!this.step.banner) {
      return;
    }
    return getUrl(this.step.banner);
  }

  @computed("step.id")
  get bannerAndDescriptionClass() {
    return `wizard-banner-and-description wizard-banner-and-description-${this.step.id}`;
  }

  @computed("step.fields.[]")
  get primaryButtonIndex() {
    return this.step.fields.length + 1;
  }

  @computed("step.fields.[]")
  get secondaryButtonIndex() {
    return this.step.fields.length + 2;
  }

  @observes("step.id")
  _stepChanged() {
    this.set("saving", false);
    this.autoFocus();
  }

  @observes("step.message")
  _handleMessage() {
    const message = this.get("step.message");
    this.onShowMessage(message);
  }

  @computed("step.index", "wizard.totalSteps")
  get barStyle() {
    let ratio =
      parseFloat(this.step.index) / parseFloat(this.wizard.totalSteps - 1);
    if (ratio < 0) {
      ratio = 0;
    }
    if (ratio > 1) {
      ratio = 1;
    }

    return trustHTML(`width: ${ratio * 200}px`);
  }

  @computed("step.fields")
  get includeSidebar() {
    return this.step.fields.some((field) => field.show_in_sidebar);
  }

  autoFocus() {
    discourseLater(() => {
      schedule("afterRender", () => {
        if (document.querySelector(".invalid .wizard-focusable")) {
          this.animateInvalidFields();
        }
      });
    });
  }

  animateInvalidFields() {
    schedule("afterRender", () => {
      const invalid = document.querySelector(".invalid .wizard-focusable");
      if (invalid) {
        window.scrollTo({
          top: invalid.getBoundingClientRect().top + window.scrollY - 200,
          behavior: "smooth",
        });
      }
    });
  }

  advance() {
    this.set("saving", true);
    this.get("step")
      .save()
      .then((response) => {
        updateCachedWizard(CustomWizard.build(response["wizard"]));

        if (response["final"]) {
          CustomWizard.finished(response);
        } else {
          this.goNext(response);
        }
      })
      .catch(() => this.animateInvalidFields())
      .finally(() => this.set("saving", false));
  }

  @action
  quit() {
    this.wizard.skip();
  }

  @action
  done() {
    this.nextStep();
  }

  @action
  showMessage(message) {
    this.onShowMessage(message);
  }

  @action
  stylingDropdownChanged(id, value) {
    this.set("stylingDropdown", { id, value });
  }

  @action
  exitEarly() {
    const step = this.step;
    step.validate();

    if (step.get("valid")) {
      this.set("saving", true);

      step
        .save()
        .then(() => this.quit())
        .finally(() => this.set("saving", false));
    } else {
      this.autoFocus();
    }
  }

  @action
  backStep() {
    if (this.saving) {
      return;
    }

    this.goBack();
  }

  @action
  nextStep() {
    if (this.saving) {
      return;
    }

    this.step.validate();

    if (this.step.get("valid")) {
      this.advance();
    } else {
      this.autoFocus();
    }
  }
}
