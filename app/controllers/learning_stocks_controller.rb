class LearningStocksController < ApplicationController
  def new
    @learning_stock = LearningStock.new
    @writer = Writer.find(params[:writer_id])
  end
end
