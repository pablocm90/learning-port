# frozen_string_literal: true

# :nodoc:
class LearningStock < ApplicationRecord
  include TranslateEnum

  belongs_to :writer

  after_create_commit :broadcast_later
  after_create_commit :broadcast_later_edit

  after_update_commit :broadcast_later_update

  enum level_of_competence: {
    not: 0,
    litle: 1,
    some: 2,
    dangerous: 3,
    enough: 4,
    competent: 5,
    good: 6,
    everyday: 7
  }
  translate_enum :level_of_competence

  private

  def broadcast_later
    broadcast_prepend_later_to :learning_stocks
  end

  def broadcast_later_edit
    broadcast_prepend_later_to :edit_learning_stocks,
                               target: 'edit_learning_stocks',
                               partial: 'learning_stocks/editable_learning_stock'
  end

  def broadcast_later_update
    broadcast_replace_later_to :learning_stocks
  end
end
