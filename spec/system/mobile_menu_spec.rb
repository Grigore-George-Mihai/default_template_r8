# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Mobile menu", :mobile, type: :system do
  let(:user) { create(:user) }
  let(:menu_button) { find("summary", text: "Open main menu", visible: :all) }

  before do
    sign_in user
    visit root_path
  end

  it "opens over the page without moving the menu button" do
    top_before = menu_button.evaluate_script("this.getBoundingClientRect().top")

    menu_button.click

    expect(page).to have_link("Profile")
    expect(menu_button.evaluate_script("this.getBoundingClientRect().top")).to eq(top_before)
  end

  it "signs out from the menu" do
    menu_button.click
    click_link "Logout"

    expect(page).to have_current_path(new_user_session_path)
  end
end
