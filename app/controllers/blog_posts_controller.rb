class BlogPostsController < ApplicationController
  def latest
    @post = BlogFeedService.fetch_latest
  end
end
