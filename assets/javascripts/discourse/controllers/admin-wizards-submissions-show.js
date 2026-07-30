import Controller from "@ember/controller";
import { action, computed } from "@ember/object";
import { service } from "@ember/service";
import AdminWizardsColumnsModal from "../components/modal/admin-wizards-columns";
import { formatModel } from "../lib/wizard-submission";
import CustomWizardAdmin from "../models/custom-wizard-admin";

export default class AdminWizardsSubmissionsShow extends Controller {
  @service modal;

  page = 0;
  total = 0;

  @computed("wizard.id")
  get downloadUrl() {
    return `/admin/wizards/submissions/${this.wizard.id}/download`;
  }

  @computed("submissions.[]")
  get noResults() {
    return this.submissions.length === 0;
  }

  loadMoreSubmissions() {
    const page = this.get("page");
    const wizardId = this.get("wizard.id");

    this.set("loadingMore", true);
    CustomWizardAdmin.submissions(wizardId, page)
      .then((result) => {
        if (result.submissions) {
          const { submissions } = formatModel(result);

          this.set("submissions", [...this.submissions, ...submissions]);
        }
      })
      .finally(() => {
        this.set("loadingMore", false);
      });
  }

  @computed("submissions.[]", "fields.@each.enabled")
  get displaySubmissions() {
    const result = [];
    const enabledFields = this.fields.filter((field) => field.enabled);

    this.submissions.forEach((submission) => {
      const sub = {};
      enabledFields.forEach((field) => {
        sub[field.id] = submission[field.id];
      });
      result.push(sub);
    });

    return result;
  }

  @action
  loadMore() {
    if (!this.loadingMore && this.submissions.length < this.total) {
      this.set("page", this.page + 1);
      this.loadMoreSubmissions();
    }
  }

  @action
  showEditColumnsModal() {
    return this.modal.show(AdminWizardsColumnsModal, {
      model: {
        columns: this.fields,
        reset: () => {
          this.fields.forEach((field) => {
            field.set("enabled", true);
          });
        },
      },
    });
  }
}
