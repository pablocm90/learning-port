class Category < ApplicationRecord
  has_many :learning_moments, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:position) }
end
