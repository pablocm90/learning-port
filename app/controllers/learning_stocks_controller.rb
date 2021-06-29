# frozen_string_literal: true

# :nodoc:
class LearningStocksController < ApplicationController
  def new
    @learning_stock = LearningStock.new
    @writer = Writer.find(params[:writer_id])
  end

  def create
    @learning_stock = LearningStock.new(stock_params)
    @writer = Writer.find(params[:writer_id])
    if @learning_stock.save
      redirect_to new_writer_learning_stock_path(current_writer)
    else
      render :new
    end
  end

  def edit
    @writer = Writer.find(params[:writer_id])
    @learning_stock = LearningStock.find(params[:id])
  end

  def update
    learning_stock = LearningStock.find(params[:id])
    if learning_stock.update(stock_params)
      render partial: 'editable_learning_stock', locals: { learning_stock: learning_stock }
    else
      render :edit
    end
  end

  private

  def stock_params
    params.require(:learning_stock).permit(
      :name,
      :icon,
      :desired_weight,
      :level_of_competence,
      :writer_id
    )
  end
end
