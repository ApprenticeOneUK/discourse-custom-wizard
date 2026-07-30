import Component from "@glimmer/component";
import { action } from "@ember/object";
import { i18n } from "discourse-i18n";

export default class AdminWizardsColumnComponent extends Component {
  title = i18n("admin.wizard.edit_columns");

  @action
  save() {
    this.args.closeModal();
  }

  @action
  resetToDefault() {
    this.args.model.reset();
  }
}
