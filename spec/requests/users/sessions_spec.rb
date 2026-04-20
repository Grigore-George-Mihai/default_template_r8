# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /users/sign_in" do
    it "returns 200" do
      get new_user_session_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users/sign_in" do
    context "with valid credentials" do
      it "signs in and redirects to root" do
        post user_session_path, params: { user: { email: user.email, password: "Password123!" } }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid credentials" do
      it "returns 422" do
        post user_session_path, params: { user: { email: user.email, password: "wrong" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /users/sign_out" do
    before { sign_in user }

    it "signs out and redirects" do
      delete destroy_user_session_path
      expect(response).to have_http_status(:redirect)
    end
  end
end
