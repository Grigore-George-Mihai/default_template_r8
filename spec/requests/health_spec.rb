# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health check", type: :request do
  describe "GET /up" do
    it "returns 200" do
      get rails_health_check_path
      expect(response).to have_http_status(:ok)
    end
  end
end
