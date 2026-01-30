class PodcastEpisode < ApplicationRecord
  validates :title, presence: true
  validates :episode_number, presence: true, uniqueness: true

  scope :newest_first, -> { order(published_at: :desc) }
  scope :published, -> { where('published_at <= ?', Date.current) }
end
