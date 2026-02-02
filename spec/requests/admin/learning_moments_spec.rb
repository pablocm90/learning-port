require 'rails_helper'

RSpec.describe "Admin::LearningMoments", type: :request do
  let(:writer) { create(:writer) }
  let(:category) { create(:category) }

  before { sign_in writer }

  describe "GET /admin/learning_moments/new" do
    it "returns success" do
      get new_admin_learning_moment_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/learning_moments" do
    it "creates a new learning moment" do
      expect {
        post admin_learning_moments_path, params: {
          learning_moment: {
            category_id: category.id,
            engagement_type: "consumed",
            description: "Read a great book",
            occurred_at: Date.today
          }
        }
      }.to change(LearningMoment, :count).by(1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "GET /admin/learning_moments/:id/edit" do
    it "returns success" do
      moment = create(:learning_moment)
      get edit_admin_learning_moment_path(moment)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/learning_moments/:id" do
    it "updates the learning moment" do
      moment = create(:learning_moment, description: "Old description")
      patch admin_learning_moment_path(moment), params: {
        learning_moment: { description: "New description" }
      }

      expect(moment.reload.description).to eq("New description")
      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "DELETE /admin/learning_moments/:id" do
    it "deletes the learning moment" do
      moment = create(:learning_moment)

      expect {
        delete admin_learning_moment_path(moment)
      }.to change(LearningMoment, :count).by(-1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end
end
