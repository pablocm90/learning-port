class LearningItemsController < ApplicationController
  def index
    @items_by_category = LearningItem.ordered.group_by(&:category)
  end

  def show
    @learning_item = LearningItem.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
