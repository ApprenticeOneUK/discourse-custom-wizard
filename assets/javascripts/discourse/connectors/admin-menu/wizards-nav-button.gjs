import Component from "@glimmer/component";
import DNavItem from "discourse/ui-kit/d-nav-item";

export default class WizardsNavButtonConnector extends Component {
  static shouldRender(_args, { currentUser }) {
    return currentUser?.admin;
  }

  <template>
    <DNavItem @route="adminWizards" @label="admin.wizard.nav_label" />
  </template>
}
