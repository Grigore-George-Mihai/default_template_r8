# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin dashboards", type: :request do
  %w[/sidekiq /pghero].each do |path|
    describe "GET #{path}" do
      it "redirects guests to sign in" do
        get path
        # Path helpers here would inherit the engine's script_name from the last request.
        expect(response).to redirect_to(Rails.application.routes.url_helpers.new_user_session_path)
      end

      it "returns 404 for non-admin users" do
        sign_in create(:user)
        get path
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
