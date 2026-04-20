# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Registrations", type: :request do
  describe "GET /users/sign_up" do
    it "returns 200" do
      get new_user_registration_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    let(:valid_params) do
      {
        user: {
          first_name: "Jane",
          last_name: "Doe",
          email: "jane@example.com",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    context "with valid params" do
      it "creates a user and redirects to root" do
        expect { post user_registration_path, params: valid_params }.to change(User, :count).by(1)
        expect(response).to redirect_to(root_path)
      end
    end

    context "with missing first_name" do
      it "does not create a user and returns 422" do
        params = valid_params.deep_merge(user: { first_name: "" })
        expect { post user_registration_path, params: params }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with mismatched passwords" do
      it "does not create a user and returns 422" do
        params = valid_params.deep_merge(user: { password_confirmation: "Different1!" })
        expect { post user_registration_path, params: params }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /users/edit" do
    context "when not signed in" do
      it "redirects to sign-in" do
        get edit_user_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "returns 200" do
        get edit_user_registration_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
