require 'rails_helper'

RSpec.describe "Admin::LearningItems", type: :request do
  let(:writer) { create(:writer) }

  before { sign_in writer }

  describe "GET /admin/learning_items/new" do
    it "returns success" do
      get new_admin_learning_item_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/learning_items" do
    it "creates a learning item" do
      expect {
        post admin_learning_items_path, params: {
          learning_item: {
            name: "Ruby",
            category: "Languages",
            status: "learning",
            icon: "💎"
          }
        }
      }.to change(LearningItem, :count).by(1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "PATCH /admin/learning_items/:id" do
    let(:item) { create(:learning_item) }

    it "updates the learning item" do
      patch admin_learning_item_path(item), params: {
        learning_item: { name: "Updated Name" }
      }

      expect(item.reload.name).to eq("Updated Name")
    end
  end

  describe "DELETE /admin/learning_items/:id" do
    let!(:item) { create(:learning_item) }

    it "deletes the learning item" do
      expect {
        delete admin_learning_item_path(item)
      }.to change(LearningItem, :count).by(-1)
    end
  end
end
