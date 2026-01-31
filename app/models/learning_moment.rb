class LearningMoment < ApplicationRecord
  belongs_to :category

  enum :engagement_type, { consumed: 0, experimented: 1, applied: 2, shared: 3 }

  validates :description, presence: true
  validates :engagement_type, presence: true
  validates :occurred_at, presence: true

  scope :chronological, -> { order(:occurred_at) }

  WEIGHTS = { consumed: 1, experimented: 2, applied: 3, shared: 4 }.freeze

  def weight
    WEIGHTS[engagement_type.to_sym]
  end
end
