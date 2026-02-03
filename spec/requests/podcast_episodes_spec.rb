require 'rails_helper'

RSpec.describe "PodcastEpisodes", type: :request do
  describe "GET /podcast" do
    it "returns success" do
      get podcast_path
      expect(response).to have_http_status(:success)
    end

    it "displays category badges on episodes" do
      episode = create(:podcast_episode, published_at: 1.day.ago)
      category = create(:podcast_category, name: "Software Practices")
      episode.podcast_categories << category

      get podcast_path

      expect(response.body).to include("Software Practices")
    end

    it "displays episodes newest first" do
      old = create(:podcast_episode, title: "Old Episode", published_at: 1.week.ago)
      new_ep = create(:podcast_episode, title: "New Episode", published_at: 1.day.ago)

      get podcast_path

      expect(response.body.index("New Episode")).to be < response.body.index("Old Episode")
    end
  end
end
