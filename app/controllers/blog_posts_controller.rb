class BlogPostsController < ApplicationController
  def latest
    @post = BlogFeedService.fetch_latest

    respond_to do |format|
      format.turbo_stream
      format.html { render partial: 'blog_posts/latest', locals: { post: @post } }
    end
  end
end
