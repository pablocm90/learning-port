class PodcastEpisodeCategory < ApplicationRecord
  belongs_to :podcast_episode
  belongs_to :podcast_category
end
