# frozen_string_literal: true
module CustomWizardUsersController
  def perform_account_activation
    destination = cookies[:destination_url]
    super

    # Core consumes destination_url before choosing the required wizard. Capture
    # only after successful activation has authenticated this exact user.
    if @user && current_user&.id == @user.id && current_user.redirect_to_wizard
      wizard = CustomWizard::Wizard.create(current_user.redirect_to_wizard, current_user)
      CustomWizard::EventReturn.capture(current_user, wizard, destination)
    end
  end

  def account_created
    if current_user.present? && (wizard = CustomWizard::Wizard.after_signup(current_user))
      CustomWizard::EventReturn.capture(current_user, wizard, cookies[:destination_url])
      return redirect_to "/w/#{wizard.id.dasherize}"
    end
    super
  end
end
