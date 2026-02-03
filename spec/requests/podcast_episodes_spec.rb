require 'rails_helper'

RSpec.describe "PodcastEpisodes", type: :request do
  describe "GET /podcast" do
    it "returns success" do
      get podcast_path
      expect(response).to have_http_status(:success)
    end

    it "displays category cards" do
      category = create(:podcast_category, name: "Software Practices")
      create(:podcast_episode, published_at: 1.day.ago).podcast_categories << category

      get podcast_path

      expect(response.body).to include("Software Practices")
    end

    it "displays episode count per category" do
      category = create(:podcast_category, name: "Software Practices")
      create(:podcast_episode, published_at: 1.day.ago).podcast_categories << category
      create(:podcast_episode, published_at: 1.day.ago).podcast_categories << category

      get podcast_path

      expect(response.body).to include("2")
    end

    it "displays a See all card" do
      get podcast_path
      expect(response.body).to include("See all")
    end
  end

  describe "GET /podcast/collections/all" do
    it "returns success" do
      get podcast_collection_path("all")
      expect(response).to have_http_status(:success)
    end

    it "displays all episodes newest first" do
      old = create(:podcast_episode, title: "Old Episode", published_at: 1.week.ago)
      new_ep = create(:podcast_episode, title: "New Episode", published_at: 1.day.ago)

      get podcast_collection_path("all")

      expect(response.body.index("New Episode")).to be < response.body.index("Old Episode")
    end

    it "displays category badges on episodes" do
      episode = create(:podcast_episode, published_at: 1.day.ago)
      category = create(:podcast_category, name: "Software Practices")
      episode.podcast_categories << category

      get podcast_collection_path("all")

      expect(response.body).to include("Software Practices")
    end
  end

  describe "GET /podcast/collections/:slug" do
    it "returns success" do
      category = create(:podcast_category, slug: "software-practices")

      get podcast_collection_path(category.slug)
      expect(response).to have_http_status(:success)
    end

    it "displays only episodes in that category" do
      cat1 = create(:podcast_category, slug: "software-practices")
      cat2 = create(:podcast_category, slug: "career")

      ep1 = create(:podcast_episode, title: "In Category", published_at: 1.day.ago)
      ep1.podcast_categories << cat1
      ep2 = create(:podcast_episode, title: "Other Category", published_at: 1.day.ago)
      ep2.podcast_categories << cat2

      get podcast_collection_path(cat1.slug)

      expect(response.body).to include("In Category")
      expect(response.body).not_to include("Other Category")
    end

    it "returns 404 for unknown slug" do
      get podcast_collection_path("nonexistent")
      expect(response).to have_http_status(:not_found)
    end

    it "displays the category name as heading" do
      category = create(:podcast_category, name: "Software Practices", slug: "software-practices")

      get podcast_collection_path(category.slug)

      expect(response.body).to include("Software Practices")
    end
  end
end
