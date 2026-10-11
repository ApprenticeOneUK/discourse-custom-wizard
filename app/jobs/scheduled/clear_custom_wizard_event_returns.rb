# frozen_string_literal: true

module Jobs
  class ClearCustomWizardEventReturns < ::Jobs::Scheduled
    every 1.day

    def execute(_args)
      PluginStoreRow
        .where(plugin_name: CustomWizard::EventReturn::STORE)
        .where("(value::json ->> 'expires_at')::bigint <= ?", Time.now.to_i)
        .delete_all
    end
  end
end
