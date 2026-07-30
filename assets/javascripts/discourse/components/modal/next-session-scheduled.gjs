import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DButton from "discourse/ui-kit/d-button";
import DDateTimeInput from "discourse/ui-kit/d-date-time-input";
import DModal from "discourse/ui-kit/d-modal";
import { i18n } from "discourse-i18n";

export default class NextSessionScheduledComponent extends Component {
  @tracked bufferedDateTime;
  title = i18n("admin.wizard.after_time_modal.title");

  constructor() {
    super(...arguments);
    this.bufferedDateTime = this.args.model.dateTime
      ? moment(this.args.model.dateTime)
      : moment(Date.now());
  }

  get submitDisabled() {
    return moment().isAfter(this.bufferedDateTime);
  }

  @action
  submit() {
    const dateTime = this.bufferedDateTime;
    this.args.model.update(moment(dateTime).utc().toISOString());
    this.args.closeModal();
  }

  @action
  dateTimeChanged(dateTime) {
    this.bufferedDateTime = dateTime;
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      class="next-session-time-modal"
      @title={{this.title}}
    >
      <DDateTimeInput
        @date={{this.bufferedDateTime}}
        @onChange={{this.dateTimeChanged}}
        @showTime="true"
        @clearable="true"
      />
      <div class="modal-footer">
        <DButton
          @action={{this.submit}}
          class="btn-primary"
          @label="admin.wizard.after_time_modal.done"
          @disabled={{this.submitDisabled}}
        />
      </div>
    </DModal>
  </template>
}
