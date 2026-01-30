require 'rss'
require 'open-uri'

class BlogFeedService
  FEED_URL = ENV.fetch('BLOG_RSS_URL', 'https://blog.example.com/feed.xml')
  CACHE_KEY = 'latest_blog_post'
  CACHE_DURATION = 15.minutes

  def self.fetch_latest
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_DURATION) do
      fetch_from_feed
    end
  end

  def self.fetch_from_feed
    content = URI.open(FEED_URL, read_timeout: 5).read
    feed = RSS::Parser.parse(content, false)

    return nil unless feed&.items&.any?

    item = feed.items.first
    {
      title: item.title,
      url: item.link,
      description: truncate_html(item.description),
      published_at: item.pubDate
    }
  rescue OpenURI::HTTPError, SocketError, RSS::Error, Timeout::Error => e
    Rails.logger.warn "Failed to fetch blog feed: #{e.message}"
    nil
  end

  def self.truncate_html(html, length: 200)
    return nil if html.nil?

    text = ActionController::Base.helpers.strip_tags(html)
    ActionController::Base.helpers.truncate(text, length: length)
  end
end
