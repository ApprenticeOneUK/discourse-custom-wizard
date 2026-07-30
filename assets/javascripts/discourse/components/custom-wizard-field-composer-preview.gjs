/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { schedule } from "@ember/runloop";
import { trustHTML } from "@ember/template";
import { on } from "@ember-decorators/object";
import { resolveAllShortUrls } from "pretty-text/upload-short-url";
import { ajax } from "discourse/lib/ajax";
import discourseDebounce from "discourse/lib/debounce";
import { loadOneboxes } from "discourse/lib/load-oneboxes";

export default class CustomWizardFieldComposerPreview extends Component {
  @on("init")
  updatePreview() {
    if (this.isDestroyed) {
      return;
    }

    schedule("afterRender", () => {
      if (this._state !== "inDOM" || !this.element) {
        return;
      }

      this.previewUpdated(this.element);
    });
  }

  previewUpdated(preview) {
    // Paint oneboxes
    const paintFunc = () => {
      loadOneboxes(
        preview,
        ajax,
        null,
        null,
        this.siteSettings.max_oneboxes_per_post,
        true // refresh on every load
      );
    };

    discourseDebounce(this, paintFunc, 450);

    // Short upload urls need resolution
    resolveAllShortUrls(ajax, this.siteSettings, preview);
  }

  <template>
    <div class="wizard-composer-preview d-editor-preview-wrapper">
      <div class="d-editor-preview">
        {{trustHTML this.field.preview_template}}
      </div>
    </div>
  </template>
}
