module Admin
  class PodcastEpisodesController < ApplicationController
    before_action :authenticate_writer!
    before_action :set_podcast_episode, only: [:edit, :update, :destroy]

    def new
      @podcast_episode = PodcastEpisode.new
    end

    def create
      @podcast_episode = PodcastEpisode.new(podcast_episode_params)

      if @podcast_episode.save
        redirect_to admin_dashboard_path, notice: "Podcast episode was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @podcast_episode.update(podcast_episode_params)
        redirect_to admin_dashboard_path, notice: "Podcast episode was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @podcast_episode.destroy
      redirect_to admin_dashboard_path, notice: "Podcast episode was successfully deleted."
    end

    private

    def set_podcast_episode
      @podcast_episode = PodcastEpisode.find(params[:id])
    end

    def podcast_episode_params
      params.require(:podcast_episode).permit(
        :title, :episode_number, :description, :published_at, :embed_code
      )
    end
  end
end
