import Controller from "@ember/controller";
import { action, computed } from "@ember/object";
import { underscore } from "@ember/string";
import { observes } from "discourse/lib/decorators";
import { autoTrackedArray } from "discourse/lib/tracked-tools";
import { i18n } from "discourse-i18n";
import CustomWizardManager from "../models/custom-wizard-manager";

export default class AdminWizardsManager extends Controller {
  @autoTrackedArray wizards;
  @autoTrackedArray exportWizards = [];
  @autoTrackedArray destroyWizards = [];

  messageUrl =
    "https://pavilion.tech/products/discourse-custom-wizard-plugin/documentation/wizard-manager";
  messageKey = "info";
  messageIcon = "circle-info";
  messageClass = "info";

  @computed("file")
  get importDisabled() {
    return !this.file;
  }

  @computed("exportWizards.[]")
  get exportDisabled() {
    return this.exportWizards.length === 0;
  }

  @computed("destroyWizards.[]")
  get destoryDisabled() {
    return this.destroyWizards.length === 0;
  }

  setMessage(type, key, opts = {}, items = []) {
    this.setProperties({
      messageKey: key,
      messageOpts: opts,
      messageType: type,
      messageItems: items,
    });
    setTimeout(() => {
      if (this.isDestroyed) {
        return;
      }
      this.setProperties({
        messageKey: "info",
        messageOpts: null,
        messageType: null,
        messageItems: null,
      });
    }, 10000);
  }

  buildWizardLink(wizard) {
    let html = `<a href='/admin/wizards/wizard/${wizard.id}'>${wizard.name}</a>`;
    html += `<span class='action'>${i18n(
      "admin.wizard.manager.imported"
    )}</span>`;
    return {
      icon: "circle-check",
      html,
    };
  }

  buildDestroyedItem(destroyed) {
    let html = `<span data-wizard-id="${destroyed.id}">${destroyed.name}</span>`;
    html += `<span class='action'>${i18n(
      "admin.wizard.manager.destroyed"
    )}</span>`;
    return {
      icon: "circle-check",
      html,
    };
  }

  buildFailureItem(failure) {
    return {
      icon: "circle-xmark",
      html: `${failure.id}: ${failure.messages}`,
    };
  }

  @action
  clearFile() {
    this.setProperties({
      file: null,
      filename: null,
    });
    document.getElementById("custom-wizard-file-upload").value = "";
  }

  @observes("importing", "destroying")
  setLoadingMessages() {
    if (this.importing) {
      this.setMessage("loading", "importing");
    }
    if (this.destroying) {
      this.setMessage("loading", "destroying");
    }
  }

  @action
  upload() {
    document.getElementById("custom-wizard-file-upload").click();
  }

  @action
  setFile(event) {
    const maxFileSize = 512 * 1024;
    const file = event.target.files[0];

    if (file === undefined) {
      this.set("file", null);
      return;
    }

    if (maxFileSize < file.size) {
      this.setMessage("error", "file_size_error");
      this.set("file", null);
      document.getElementById("custom-wizard-file-upload").value = "";
    } else {
      this.setProperties({
        file,
        filename: file.name,
      });
    }
  }

  @action
  selectWizard(event) {
    const type = event.target.classList.contains("export")
      ? "export"
      : "destroy";
    const wizards = this.get(`${type}Wizards`);
    const checked = event.target.checked;

    let wizardId = event.target.closest("tr").getAttribute("data-wizard-id");

    if (wizardId) {
      wizardId = underscore(wizardId);
    } else {
      return false;
    }

    if (checked) {
      if (!wizards.includes(wizardId)) {
        wizards.push(wizardId);
      }
    } else {
      const index = wizards.indexOf(wizardId);
      if (index !== -1) {
        wizards.splice(index, 1);
      }
    }
  }

  @action
  import() {
    const file = this.get("file");

    if (!file) {
      this.setMessage("error", "no_file");
      return;
    }

    const formData = new FormData();
    formData.append("file", file);

    this.set("importing", true);
    this.setMessage("loading", "importing");

    CustomWizardManager.import(formData)
      .then((result) => {
        if (result.error) {
          this.setMessage("error", "server_error", {
            message: result.error,
          });
        } else {
          this.setMessage(
            "success",
            "import_complete",
            {},
            result.imported
              .map((imported) => {
                return this.buildWizardLink(imported);
              })
              .concat(
                result.failures.map((failure) => {
                  return this.buildFailureItem(failure);
                })
              )
          );

          if (result.imported.length) {
            this.wizards.push(...result.imported);
          }
        }
        this.clearFile();
      })
      .finally(() => {
        this.set("importing", false);
      });
  }

  @action
  export() {
    const exportWizards = this.exportWizards;

    if (!exportWizards.length) {
      this.setMessage("error", "none_selected");
    } else {
      CustomWizardManager.export(exportWizards);
      exportWizards.splice(0);
      document.querySelectorAll("input.export").forEach((input) => {
        input.checked = false;
      });
    }
  }

  @action
  destroy() {
    let destroyWizards = this.destroyWizards;

    if (!destroyWizards.length) {
      this.setMessage("error", "none_selected");
    } else {
      this.set("destroying", true);

      CustomWizardManager.destroy(destroyWizards)
        .then((result) => {
          if (result.error) {
            this.setMessage("error", "server_error", {
              message: result.error,
            });
          } else {
            this.setMessage(
              "success",
              "destroy_complete",
              {},
              result.destroyed
                .map((destroyed) => {
                  return this.buildDestroyedItem(destroyed);
                })
                .concat(
                  result.failures.map((failure) => {
                    return this.buildFailureItem(failure);
                  })
                )
            );

            if (result.destroyed.length) {
              const destroyedIds = result.destroyed.map((d) => d.id);
              destroyWizards = this.destroyWizards;
              this.wizards = this.wizards.filter(
                (wizard) => !destroyedIds.includes(wizard.id)
              );

              this.destroyWizards = destroyWizards.filter(
                (wizardId) => !destroyedIds.includes(wizardId)
              );
            }
          }
        })
        .finally(() => {
          this.set("destroying", false);
        });
    }
  }
}
