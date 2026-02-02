class LearningController < ApplicationController
  def index
    @categories = Category.ordered.includes(:learning_moments)
    @max_depth = @categories.map(&:drip_depth).max || 1
  end
end
