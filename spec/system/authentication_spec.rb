# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication", type: :system do
  let(:user) { create(:user) }

  def sign_in_with_form(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
  end

  it "loads JavaScript on a visitor's first page (CSP nonce present)" do
    visit new_user_session_path

    expect(page).to have_button("Log in")
    expect(page.evaluate_script("typeof window.Turbo")).to eq("object")
  end

  it "signs in through the form and closes the flash message (Stimulus)" do
    sign_in_with_form(user)

    expect(page).to have_css("h1", text: "Everything included")
    expect(page).to have_css("[role=alert]", text: "Signed in successfully.")
    find("[role=alert]").click_button("Close")
    expect(page).to have_no_css("[role=alert]")
  end

  # Clicking (not just finding) fails if the flash sits on top of the menu.
  # Logout uses data-turbo-method: :delete, so this also only passes when Turbo is running.
  it "signs out from the account menu while a flash message is showing" do
    sign_in_with_form(user)
    expect(page).to have_css("[role=alert]")

    find("summary", text: "Account").click
    click_link "Logout"
    expect(page).to have_current_path(new_user_session_path)
  end
end
