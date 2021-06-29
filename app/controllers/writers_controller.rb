# frozen_string_literal: true

# :nodoc:
class WritersController < ApplicationController
  before_action :authenticate_writer!

  def dashboard
    @learning_stock = LearningStock.new
    @writer = current_writer
    @learning_stocks = current_writer.learning_stocks
  end
end
