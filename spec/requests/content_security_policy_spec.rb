# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Content Security Policy", type: :request do
  def script_nonce
    response.headers["content-security-policy"][/script-src[^;]*'nonce-([^']+)'/, 1]
  end

  it "sends a non-empty script nonce on a visitor's first request, matching the importmap tag" do
    get new_user_session_path

    expect(script_nonce).to be_present
    expect(response.body).to include(%(<script type="importmap" data-turbo-track="reload" nonce="#{script_nonce}">))
  end

  it "keeps the nonce stable across requests and sign-in" do
    get new_user_session_path
    first_nonce = script_nonce

    sign_in create(:user)
    get root_path

    expect(script_nonce).to eq(first_nonce)
  end
end
