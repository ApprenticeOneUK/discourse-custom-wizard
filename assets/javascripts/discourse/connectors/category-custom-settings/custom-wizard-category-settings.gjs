import CustomWizardCategorySettings from "../../components/custom-wizard-category-settings";

export default <template>
  <CustomWizardCategorySettings
    @category={{@outletArgs.category}}
    @form={{@outletArgs.form}}
    @transientData={{@outletArgs.transientData}}
  />
</template>
