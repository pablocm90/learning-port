class PodcastCategory < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:position) }
end
