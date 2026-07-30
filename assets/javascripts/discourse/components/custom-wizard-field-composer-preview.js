/* eslint-disable ember/no-classic-classes, ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { schedule } from "@ember/runloop";
import { resolveAllShortUrls } from "pretty-text/upload-short-url";
import { ajax } from "discourse/lib/ajax";
import discourseDebounce from "discourse/lib/debounce";
import { on } from "discourse/lib/decorators";
import { loadOneboxes } from "discourse/lib/load-oneboxes";

export default Component.extend({
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
  },

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
  },
});
