import AdminNav from "discourse/admin/components/admin-nav";
import PluginOutlet from "discourse/components/plugin-outlet";
import DNavItem from "discourse/ui-kit/d-nav-item";

export default <template>
  <PluginOutlet @name="admin-wizards-top" @connectorTagName="div" />

  <AdminNav>
    <DNavItem @route="adminWizardsWizard" @label="admin.wizard.nav_label" />
    <DNavItem
      @route="adminWizardsCustomFields"
      @label="admin.wizard.custom_field.nav_label"
    />
    <DNavItem
      @route="adminWizardsSubmissions"
      @label="admin.wizard.submissions.nav_label"
    />
    {{#if @controller.showApi}}
      <DNavItem @route="adminWizardsApi" @label="admin.wizard.api.nav_label" />
    {{/if}}
    <DNavItem @route="adminWizardsLogs" @label="admin.wizard.log.nav_label" />
    <DNavItem
      @route="adminWizardsManager"
      @label="admin.wizard.manager.nav_label"
    />
  </AdminNav>

  <div class="admin-container">
    {{outlet}}
  </div>
</template>
