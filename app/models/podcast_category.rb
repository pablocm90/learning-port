class PodcastCategory < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  has_many :podcast_episode_categories, dependent: :destroy
  has_many :podcast_episodes, through: :podcast_episode_categories

  before_validation :generate_slug, if: -> { slug.blank? }

  scope :ordered, -> { order(:position) }

  def self.find_by_slug!(slug)
    find_by!(slug: slug)
  end

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name&.parameterize
  end
end
