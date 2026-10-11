# frozen_string_literal: true

describe "Event signup return", type: :request do
  fab!(:user) { Fabricate(:user, active: false, first_seen_at: nil) }
  fab!(:topic)
  let(:destination) { "/t/-/#{topic.id}?event_sign_in=#{"a" * 32}" }
  let(:return_url) { "#{topic.relative_url}?event_sign_in=#{"a" * 32}" }
  let(:template) do
    get_wizard_fixture("wizard").tap do |wizard|
      wizard["after_signup"] = true
      wizard["required"] = true
      wizard["actions"] = []
    end
  end

  before do
    SiteSetting.wizard_event_return_enabled = true
    CustomWizard::Template.save(template, skip_jobs: true)
    UsersController.any_instance.stubs(:honeypot_or_challenge_fails?).returns(false)
  end

  def activate
    token = Fabricate(:email_token, user: user)
    cookies[:destination_url] = destination
    put "/u/activate-account/#{token.token}"
    expect(response.status).to eq(200)
    expect(response.parsed_body["redirect_to"]).to end_with("/w/super-mega-fun-wizard")
  end

  def finish
    %w[step_1 step_2 step_3].each do |step|
      put "/w/super-mega-fun-wizard/steps/#{step}.json"
      expect(response.status).to eq(200)
    end
  end

  def pending
    PluginStore.get(CustomWizard::EventReturn::STORE, user.id.to_s)
  end

  it "returns the activated user to their event after Welcome, despite a homepage visit" do
    activate
    expect(cookies[:destination_url]).to be_blank
    get "/", headers: { "REFERER" => Discourse.base_url + "/" }
    expect(response).to redirect_to("/w/super-mega-fun-wizard")
    finish
    expect(response.parsed_body["final"]).to eq(true)
    expect(response.parsed_body["redirect_on_complete"]).to eq(return_url)
    expect(pending).to be_nil
    get return_url
    expect(response.status).to eq(200)
    expect(user.reload.redirect_to_wizard).to be_nil
  end

  it "survives resuming Welcome in another authenticated session" do
    activate
    another_tab = open_session
    another_tab.cookies[:_t] = cookies[:_t]
    %w[step_1 step_2 step_3].each do |step|
      another_tab.put "/w/super-mega-fun-wizard/steps/#{step}.json"
      expect(another_tab.response.status).to eq(200)
    end
    expect(another_tab.response.parsed_body["redirect_on_complete"]).to eq(return_url)
    expect(pending).to be_nil
  end

  it "completes real signup and the emailed activation token in a new browser tab" do
    UsersController.any_instance.unstub(:honeypot_or_challenge_fails?)
    SiteSetting.allow_new_registrations = true
    cookies[:destination_url] = destination
    get "/session/hp.json"
    honeypot = response.parsed_body
    post "/u.json",
         params: {
           username: "event_return_signup",
           email: "event-return-signup@example.com",
           password: "TestOnly-Fictional-Passphrase-2026",
           password_confirmation: honeypot["value"],
           challenge: honeypot["challenge"].reverse,
         }
    expect(response.status).to eq(200)
    expect(response.parsed_body["success"]).to eq(true)
    created_user = User.find_by!(username: "event_return_signup")
    expect(created_user.active).to eq(false)
    mail_job =
      Jobs::CriticalUserEmail.jobs.find { |job| job["args"].first["user_id"] == created_user.id }
    expect(mail_job).to be_present
    token = mail_job["args"].first["email_token"]

    # A second tab shares the site's cookie, but not the theme's sessionStorage.
    activation_tab = open_session
    activation_tab.cookies[:destination_url] = cookies[:destination_url]
    activation_tab.get "/session/hp.json"
    honeypot = activation_tab.response.parsed_body
    activation_tab.put "/u/activate-account/#{token}",
                       params: {
                         password_confirmation: honeypot["value"],
                         challenge: honeypot["challenge"].reverse,
                       }
    expect(activation_tab.response.status).to eq(200)
    expect(activation_tab.response.parsed_body["redirect_to"]).to end_with(
      "/w/super-mega-fun-wizard",
    )
    %w[step_1 step_2 step_3].each do |step|
      activation_tab.put "/w/super-mega-fun-wizard/steps/#{step}.json"
      expect(activation_tab.response.status).to eq(200)
    end
    expect(activation_tab.response.parsed_body["redirect_on_complete"]).to eq(return_url)
    activation_tab.get return_url
    expect(activation_tab.response.status).to eq(200)
    expect(created_user.reload.active).to eq(true)
    expect(created_user.redirect_to_wizard).to be_nil
  end

  it "does not depend on saving submission history" do
    template["save_submissions"] = false
    CustomWizard::Template.save(template, skip_jobs: true)
    activate
    finish
    expect(response.parsed_body["redirect_on_complete"]).to eq(return_url)
  end

  it "retains the destination through a validation error" do
    template["steps"][0]["fields"][0]["required"] = true
    CustomWizard::Template.save(template, skip_jobs: true)
    activate
    put "/w/super-mega-fun-wizard/steps/step_1.json", params: { fields: { step_1_field_1: "x" } }
    expect(response.status).to eq(422)
    expect(pending[:destination]).to eq(destination)
    put "/w/super-mega-fun-wizard/steps/step_1.json",
        params: {
          fields: {
            step_1_field_1: "Valid answer",
          },
        }
    %w[step_2 step_3].each { |step| put "/w/super-mega-fun-wizard/steps/#{step}.json" }
    expect(response.parsed_body["redirect_on_complete"]).to eq(return_url)
  end

  it "does not extend the expiry when the user visits the homepage" do
    activate
    expires_at = pending[:expires_at]
    freeze_time 1.hour.from_now
    cookies[:destination_url] = destination
    get "/"
    expect(pending[:expires_at]).to eq(expires_at)
    freeze_time 25.hours.from_now
    finish
    expect(response.parsed_body["redirect_on_complete"]).not_to eq(return_url)
    expect(pending).to be_nil
  end

  it "rechecks access after onboarding instead of exposing a private event" do
    activate
    topic.update!(category: Fabricate(:private_category, group: Fabricate(:group)))
    finish
    expect(response.parsed_body["redirect_on_complete"]).not_to eq(return_url)
    expect(pending).to be_nil
  end

  it "does not return to a deleted event" do
    activate
    topic.trash!
    finish
    expect(response.parsed_body["redirect_on_complete"]).not_to eq(return_url)
    expect(pending).to be_nil
  end

  it "checks access after a successful completion action grants event membership" do
    group = Fabricate(:group)
    topic.update!(category: Fabricate(:private_category, group: group))
    action = get_wizard_fixture("actions/add_to_group")
    action["run_after"] = "wizard_completion"
    action["group"] = [
      {
        "type" => "assignment",
        "output" => group.id,
        "output_type" => "text",
        "output_connector" => "set",
      },
    ]
    template["actions"] = [action]
    CustomWizard::Template.save(template, skip_jobs: true)
    activate
    expect(Guardian.new(user).can_see?(topic)).to eq(false)
    finish
    expect(group.users.exists?(id: user.id)).to eq(true)
    expect(response.parsed_body["redirect_on_complete"]).to eq(return_url)
  end

  it "does not capture an optional signup wizard" do
    template["required"] = false
    CustomWizard::Template.save(template, skip_jobs: true)
    activate
    expect(pending).to be_nil
  end

  it "consumes a return once and only for its own user" do
    activate
    other = Fabricate(:user)
    expect(
      CustomWizard::EventReturn.consume(CustomWizard::Wizard.create(template["id"], other)),
    ).to be_nil
    expect(pending).to be_present
    finish
    expect(
      CustomWizard::EventReturn.consume(CustomWizard::Wizard.create(template["id"], user)),
    ).to be_nil
  end

  it "removes expired abandoned handoffs without touching a current one" do
    activate
    Jobs::ClearCustomWizardEventReturns.new.execute({})
    expect(pending).to be_present
    freeze_time 25.hours.from_now
    Jobs::ClearCustomWizardEventReturns.new.execute({})
    expect(pending).to be_nil
  end

  it "keeps explicit wizard action redirects" do
    action = get_wizard_fixture("actions/route_to")
    action["run_after"] = "wizard_completion"
    template["actions"] = [action]
    CustomWizard::Template.save(template, skip_jobs: true)
    activate
    finish
    expect(response.parsed_body["redirect_on_complete"]).to eq("https://google.com")
    expect(pending).to be_nil
  end

  it "does not claim a successful event return when a completion action fails" do
    action = get_wizard_fixture("actions/create_group_bad_user")
    action["run_after"] = "wizard_completion"
    template["actions"] = [action]
    CustomWizard::Template.save(template, skip_jobs: true)
    activate
    finish
    expect(response.parsed_body["redirect_on_complete"]).not_to eq(return_url)
    expect(pending).to be_nil
  end

  it "leaves ordinary signup's entry destination unchanged" do
    token = Fabricate(:email_token, user: user)
    cookies[:destination_url] = "/latest"
    put "/u/activate-account/#{token.token}"
    get "/", headers: { "REFERER" => Discourse.base_url + "/latest" }
    finish
    expect(response.parsed_body["redirect_on_complete"]).to eq(Discourse.base_url + "/latest")
    expect(pending).to be_nil
  end

  it "stays disabled until an administrator enables it" do
    SiteSetting.wizard_event_return_enabled = false
    activate
    expect(pending).to be_nil
    finish
    expect(response.parsed_body["redirect_on_complete"]).not_to eq(return_url)
  end

  it "does not bind another user's cookie when activation fails" do
    cookies[:destination_url] = destination
    put "/u/activate-account/123abc"
    expect(response.status).to eq(422)
    expect(pending).to be_nil
  end

  it "captures account-created handoff for a user who is already authenticated" do
    user.update!(active: true)
    sign_in(user)
    cookies[:destination_url] = destination
    get "/u/account-created"
    expect(response).to redirect_to("/w/super-mega-fun-wizard")
    finish
    expect(response.parsed_body["redirect_on_complete"]).to eq(return_url)
  end

  it "captures a marked event request interrupted by required Welcome" do
    user.update!(active: true)
    CustomWizard::Wizard.set_user_redirect(template["id"], user)
    sign_in(user)
    get destination
    expect(response).to redirect_to("/w/super-mega-fun-wizard")
    finish
    expect(response.parsed_body["redirect_on_complete"]).to eq(return_url)
  end

  it "does not consume the handoff when a different wizard is completed" do
    activate
    other = template.deep_dup
    other["id"] = "other_wizard"
    other["after_signup"] = false
    CustomWizard::Template.save(other, skip_jobs: true)
    %w[step_1 step_2 step_3].each { |step| put "/w/other-wizard/steps/#{step}.json" }
    expect(response.parsed_body["redirect_on_complete"]).not_to eq(return_url)
    expect(pending[:destination]).to eq(destination)
    finish
    expect(response.parsed_body["redirect_on_complete"]).to eq(return_url)
  end

  %w[
    https://evil.example/t/-/1?event_sign_in=
    //evil.example/
    /login?event_sign_in=
    /t/-/1?extra=1&event_sign_in=
    /t/%2f/1?event_sign_in=
    /t/-/999999999999999999999999999?event_sign_in=
  ].each do |prefix|
    it "rejects an untrusted destination starting with #{prefix}" do
      token = Fabricate(:email_token, user: user)
      cookies[:destination_url] = prefix + "a" * 32
      put "/u/activate-account/#{token.token}"
      expect(pending).to be_nil
    end
  end
end
