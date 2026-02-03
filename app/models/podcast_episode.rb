class PodcastEpisode < ApplicationRecord
  validates :title, presence: true
  validates :episode_number, presence: true, uniqueness: true

  has_many :podcast_episode_categories, dependent: :destroy
  has_many :podcast_categories, through: :podcast_episode_categories

  scope :newest_first, -> { order(published_at: :desc) }
  scope :published, -> { where('published_at <= ?', Date.current) }
end
