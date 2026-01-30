module Admin
  class LearningItemsController < ApplicationController
    before_action :authenticate_writer!
    before_action :set_learning_item, only: [:edit, :update, :destroy]

    def new
      @learning_item = LearningItem.new
    end

    def create
      @learning_item = LearningItem.new(learning_item_params)
      @learning_item.source = 'admin'

      if @learning_item.save
        redirect_to admin_dashboard_path, notice: "Learning item was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @learning_item.update(learning_item_params)
        redirect_to admin_dashboard_path, notice: "Learning item was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @learning_item.destroy
      redirect_to admin_dashboard_path, notice: "Learning item was successfully deleted."
    end

    private

    def set_learning_item
      @learning_item = LearningItem.find(params[:id])
    end

    def learning_item_params
      params.require(:learning_item).permit(
        :name, :icon, :category, :status, :started_at, :position,
        :description, :notes
      )
    end
  end
end
