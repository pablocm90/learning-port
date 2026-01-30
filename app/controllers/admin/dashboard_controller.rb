module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_writer!

    def index
      @learning_items = LearningItem.ordered
      @podcast_episodes = PodcastEpisode.newest_first
    end
  end
end
