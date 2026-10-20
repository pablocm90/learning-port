require "net/http"
require "rss"

class BlogFeedService
  CACHE_KEY = "latest_blog_post"
  CACHE_DURATION = 15.minutes

  def self.fetch_latest
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_DURATION) do
      fetch_from_rss
    end
  end

  def self.fetch_from_rss
    uri = URI(ENV.fetch("BLOG_RSS_URL"))
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 5) do |http|
      http.get(uri.request_uri)
    end

    post = RSS::Parser.parse(response.body, false).items.first
    return nil unless post

    {
      title: post.title,
      url: post.link,
      description: truncate_text(post.description),
      published_at: post.pubDate
    }
  rescue StandardError => e
    Rails.logger.warn "Failed to fetch blog RSS feed: #{e.message}"
    nil
  end

  def self.truncate_text(text, length: 200)
    return nil if text.nil?
    ActionController::Base.helpers.truncate(text, length: length)
  end
end
