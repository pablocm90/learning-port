class PagesController < ApplicationController
  def home
    @latest_episode = PodcastEpisode.published.newest_first.first
    @active_categories = Category.ordered
                                 .includes(:learning_moments)
                                 .select { |c| c.learning_moments.any? }
                                 .sort_by { |c| c.learning_moments.maximum(:occurred_at) || Date.new(1970) }
                                 .reverse
                                 .first(4)
    @max_depth = @active_categories.map(&:drip_depth).max || 1
  end
end
