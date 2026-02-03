class PodcastCategory < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :podcast_episode_categories, dependent: :destroy
  has_many :podcast_episodes, through: :podcast_episode_categories

  scope :ordered, -> { order(:position) }
end
