# frozen_string_literal: true

describe "create_topic_wizard category setting" do
  fab!(:user)
  fab!(:category) { Fabricate(:category, custom_fields: { create_topic_wizard: "my_wizard" }) }

  before do
    SiteSetting.custom_wizard_enabled = true
    Site.clear_cache
  end

  it "registers create_topic_wizard as a preloaded category custom field" do
    expect(Site.preloaded_category_custom_fields).to include("create_topic_wizard")
  end

  # Without this the client cannot see the setting, so the new topic button
  # falls back to the normal composer instead of opening the wizard.
  it "serializes create_topic_wizard onto the category in site.json" do
    sign_in(user)
    get "/site.json"

    expect(response.status).to eq(200)
    serialized = response.parsed_body["categories"].find { |c| c["id"] == category.id }
    expect(serialized).to be_present
    expect(serialized.dig("custom_fields", "create_topic_wizard")).to eq("my_wizard")
  end
end
