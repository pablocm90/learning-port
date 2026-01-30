class PodcastEpisodesController < ApplicationController
  def index
    @episodes = PodcastEpisode.published.newest_first
  end
end
