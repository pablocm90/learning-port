module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_writer!

    def index
      @categories = Category.ordered.includes(:learning_moments)
      @podcast_episodes = PodcastEpisode.newest_first
    end
  end
end
