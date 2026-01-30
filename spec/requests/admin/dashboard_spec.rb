require 'rails_helper'

RSpec.describe "Admin::Dashboard", type: :request do
  describe "GET /admin" do
    context "when not signed in" do
      it "redirects to sign in" do
        get admin_dashboard_path
        expect(response).to redirect_to(new_writer_session_path)
      end
    end

    context "when signed in" do
      let(:writer) { create(:writer) }

      before { sign_in writer }

      it "returns success" do
        get admin_dashboard_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
