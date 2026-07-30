import Controller from "@ember/controller";
import { action, computed } from "@ember/object";
import { autoTrackedArray } from "discourse/lib/tracked-tools";
import CustomWizardLogs from "../models/custom-wizard-logs";

export default class AdminWizardsLogsShow extends Controller {
  @autoTrackedArray logs = [];

  refreshing = false;
  page = 0;
  canLoadMore = true;
  messageKey = "viewing";

  @computed("logs.[]")
  get hasLogs() {
    return Boolean(this.logs.length);
  }

  loadLogs() {
    if (!this.canLoadMore) {
      return;
    }
    const page = this.get("page");
    const wizardId = this.get("wizard.id");

    this.set("refreshing", true);

    CustomWizardLogs.list(wizardId, page)
      .then((result) => {
        this.set("logs", this.logs.concat(result.logs));
      })
      .finally(() => this.set("refreshing", false));
  }

  @computed("hasLogs", "refreshing")
  get noResults() {
    return !this.hasLogs && !this.refreshing;
  }

  @action
  loadMore() {
    if (!this.loadingMore && this.logs.length < this.total) {
      this.set("page", (this.page += 1));
      this.loadLogs();
    }
  }

  @action
  refresh() {
    this.setProperties({
      canLoadMore: true,
      page: 0,
      logs: [],
    });
    this.loadLogs();
  }
}
