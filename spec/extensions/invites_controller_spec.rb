# frozen_string_literal: true

describe InvitesControllerCustomWizard, type: :request do
  fab!(:topic)
  let(:invite) { Invite.generate(topic.user, email: "angus@mcleod.org", topic: topic) }
  let(:template) { get_wizard_fixture("wizard") }

  before do
    @controller = InvitesController.new
    # This spec covers the legacy invite flow, replaced by the email-code flow when enabled.
    SiteSetting.enable_local_logins_via_code = false
  end

  it "redirects a user to wizard after invite if after signup is enabled" do
    template["after_signup"] = true
    CustomWizard::Template.save(template, skip_jobs: true)
    put "/invites/show/#{invite.invite_key}.json"
    expect(response.status).to eq(200)
    expect(cookies[:destination_url]).to eq("/w/super-mega-fun-wizard")
  end
end
