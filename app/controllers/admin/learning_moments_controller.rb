module Admin
  class LearningMomentsController < ApplicationController
    before_action :authenticate_writer!
    before_action :set_learning_moment, only: [:edit, :update, :destroy]

    def new
      @learning_moment = LearningMoment.new
      @categories = Category.ordered
    end

    def create
      @learning_moment = LearningMoment.new(learning_moment_params)

      if @learning_moment.save
        redirect_to admin_dashboard_path, notice: "Learning moment was successfully created."
      else
        @categories = Category.ordered
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @categories = Category.ordered
    end

    def update
      if @learning_moment.update(learning_moment_params)
        redirect_to admin_dashboard_path, notice: "Learning moment was successfully updated."
      else
        @categories = Category.ordered
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @learning_moment.destroy
      redirect_to admin_dashboard_path, notice: "Learning moment was successfully deleted."
    end

    private

    def set_learning_moment
      @learning_moment = LearningMoment.find(params[:id])
    end

    def learning_moment_params
      params.require(:learning_moment).permit(:category_id, :engagement_type, :description, :url, :occurred_at)
    end
  end
end
