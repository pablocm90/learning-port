class PagesController < ApplicationController
  def home
    @latest_episode = PodcastEpisode.published.newest_first.first
    @learning_highlights = LearningItem.where(status: :learning).ordered.limit(4)
  end
end
