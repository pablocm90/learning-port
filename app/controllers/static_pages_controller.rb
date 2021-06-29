# frozen_string_literal: true

# :nodoc:
class StaticPagesController < ApplicationController
  def home
    @learning_stocks = LearningStock.all.order(level_of_competence: :desc)
  end
end
