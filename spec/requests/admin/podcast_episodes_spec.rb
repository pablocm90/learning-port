require 'rails_helper'

RSpec.describe "Admin::PodcastEpisodes", type: :request do
  let(:writer) { create(:writer) }

  before { sign_in writer }

  describe "GET /admin/podcast_episodes/new" do
    it "returns success" do
      get new_admin_podcast_episode_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/podcast_episodes" do
    it "creates a podcast episode" do
      expect {
        post admin_podcast_episodes_path, params: {
          podcast_episode: {
            title: "New Episode",
            episode_number: 1,
            description: "A great episode",
            published_at: Date.today
          }
        }
      }.to change(PodcastEpisode, :count).by(1)

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end

  describe "PATCH /admin/podcast_episodes/:id" do
    let(:episode) { create(:podcast_episode) }

    it "updates the podcast episode" do
      patch admin_podcast_episode_path(episode), params: {
        podcast_episode: { title: "Updated Title" }
      }

      expect(episode.reload.title).to eq("Updated Title")
    end
  end

  describe "DELETE /admin/podcast_episodes/:id" do
    let!(:episode) { create(:podcast_episode) }

    it "deletes the podcast episode" do
      expect {
        delete admin_podcast_episode_path(episode)
      }.to change(PodcastEpisode, :count).by(-1)
    end
  end
end
