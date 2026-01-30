class LearningItem < ApplicationRecord
  enum :status, { learning: 0, practicing: 1, comfortable: 2, expert: 3 }

  validates :name, presence: true
  validates :category, presence: true
  validates :status, presence: true

  scope :ordered, -> { order(:position) }
  scope :by_category, ->(category) { where(category: category) }
  scope :from_yaml, -> { where(source: 'yaml') }
  scope :from_admin, -> { where(source: 'admin') }
end
