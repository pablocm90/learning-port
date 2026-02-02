require 'rails_helper'

RSpec.describe "Admin::Categories", type: :request do
  let(:writer) { create(:writer) }

  before { sign_in writer }

  describe "GET /admin/categories/new" do
    it "returns success" do
      get new_admin_category_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/categories" do
    it "creates a new category" do
      expect {
        post admin_categories_path, params: { category: { name: "Agile", position: 1 } }
      }.to change(Category, :count).by(1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "GET /admin/categories/:id/edit" do
    it "returns success" do
      category = create(:category)
      get edit_admin_category_path(category)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/categories/:id" do
    it "updates the category" do
      category = create(:category, name: "Old Name")
      patch admin_category_path(category), params: { category: { name: "New Name" } }

      expect(category.reload.name).to eq("New Name")
      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "DELETE /admin/categories/:id" do
    it "deletes the category" do
      category = create(:category)

      expect {
        delete admin_category_path(category)
      }.to change(Category, :count).by(-1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end
end
