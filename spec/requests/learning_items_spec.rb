require 'rails_helper'

RSpec.describe "LearningItems", type: :request do
  describe "GET /learning" do
    it "returns success" do
      get learning_portfolio_path
      expect(response).to have_http_status(:success)
    end

    it "displays learning items grouped by category" do
      create(:learning_item, name: "Ruby", category: "Languages")
      create(:learning_item, name: "Rails", category: "Frameworks")

      get learning_portfolio_path

      expect(response.body).to include("Ruby")
      expect(response.body).to include("Rails")
      expect(response.body).to include("Languages")
      expect(response.body).to include("Frameworks")
    end
  end
end
