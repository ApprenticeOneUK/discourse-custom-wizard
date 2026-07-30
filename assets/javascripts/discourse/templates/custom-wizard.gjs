export default <template>
  <div class="wizard-column">
    <div class="wizard-column-contents">
      {{outlet}}
    </div>
    <div class="wizard-footer">
      {{#if @controller.customWizard}}
        <img
          src={{@controller.logoUrl}}
          style="background-image: initial; width: 33px; height: 33px;"
        />
      {{else}}
        <div class="discourse-logo"></div>
      {{/if}}
    </div>
  </div>
</template>
