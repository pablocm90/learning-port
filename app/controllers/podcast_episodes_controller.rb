class PodcastEpisodesController < ApplicationController
  def index
    @episodes = PodcastEpisode.published.newest_first.includes(:podcast_categories)
  end
end
