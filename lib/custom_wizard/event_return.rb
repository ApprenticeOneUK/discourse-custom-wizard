# frozen_string_literal: true

# A short-lived handoff from Event Sign-in to required signup onboarding.
# Kept separately from submissions, which administrators may choose not to save.
module CustomWizard::EventReturn
  STORE = "custom_wizard_event_returns"
  TTL = 24.hours
  DESTINATION = %r{\A/t/-/([1-9][0-9]{0,15})\?event_sign_in=([a-f0-9]{32})\z}

  def self.capture(user, wizard, destination)
    return unless SiteSetting.wizard_event_return_enabled && user && wizard
    return unless wizard.after_signup && wizard.required && !wizard.completed?
    return unless destination.is_a?(String) && DESTINATION.match?(destination)

    user.with_lock do
      pending = PluginStore.get(STORE, user.id.to_s)
      # A later homepage/referrer visit must not renew or replace this handoff.
      return if pending && pending[:expires_at].to_i > Time.now.to_i

      PluginStore.set(
        STORE,
        user.id.to_s,
        { wizard_id: wizard.id, destination: destination, expires_at: TTL.from_now.to_i },
      )
    end
  end

  def self.consume(wizard)
    return unless wizard.user

    wizard.user.with_lock do
      pending = PluginStore.get(STORE, wizard.user.id.to_s)
      return unless pending && pending[:wizard_id] == wizard.id

      # Consume once, including expired or inaccessible destinations.
      PluginStore.remove(STORE, wizard.user.id.to_s)
      return false unless SiteSetting.wizard_event_return_enabled
      return false unless wizard.after_signup && wizard.required
      return false if pending[:expires_at].to_i <= Time.now.to_i
      return false unless match = DESTINATION.match(pending[:destination].to_s)

      topic = Topic.find_by(id: match[1], archetype: Archetype.default)
      return false unless topic && !topic.trashed? && Guardian.new(wizard.user).can_see?(topic)

      # Core's /t/-/id canonical redirect strips unrecognised query parameters.
      # Use the current slug so the completion marker reaches the theme intact.
      "#{topic.relative_url}?event_sign_in=#{match[2]}"
    end
  end
end
