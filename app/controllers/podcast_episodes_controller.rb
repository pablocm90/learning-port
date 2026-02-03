class PodcastEpisodesController < ApplicationController
  def index
    @categories = PodcastCategory.ordered
    @total_episode_count = PodcastEpisode.published.count
    @episode_counts = PodcastEpisode.published
      .joins(:podcast_episode_categories)
      .group("podcast_episode_categories.podcast_category_id")
      .count
  end

  def show
    if params[:slug] == "all"
      @title = "All Episodes"
      @episodes = PodcastEpisode.published.newest_first.includes(:podcast_categories)
    else
      @category = PodcastCategory.find_by_slug!(params[:slug])
      @title = @category.name
      @episodes = @category.podcast_episodes.published.newest_first.includes(:podcast_categories)
    end
  end
end
