class Category < ApplicationRecord
  has_many :learning_moments, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:position) }

  def weighted_score
    learning_moments.sum(&:weight)
  end

  def time_span_days
    return 0 if learning_moments.count < 2

    dates = learning_moments.pluck(:occurred_at)
    (dates.max - dates.min).to_i
  end

  def drip_depth
    weighted_score + (time_span_days / 30.0)
  end

  def engagement_types_present
    learning_moments.distinct.pluck(:engagement_type)
  end
end
