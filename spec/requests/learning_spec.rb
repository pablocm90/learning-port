require 'rails_helper'

RSpec.describe "Learning", type: :request do
  describe "GET /learning" do
    it "returns success" do
      get learning_portfolio_path
      expect(response).to have_http_status(:success)
    end

    it "displays categories with their drips" do
      category = create(:category, name: "Agile")
      create(:learning_moment, category: category, description: "Read XP book")

      get learning_portfolio_path

      expect(response.body).to include("Agile")
      expect(response.body).to include("How I Learn")
    end

    it "shows empty state when no categories" do
      get learning_portfolio_path

      expect(response.body).to include("No learning categories yet")
    end
  end
end
