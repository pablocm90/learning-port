require 'net/http'
require 'json'

class BlogFeedService
  HASHNODE_API = 'https://gql.hashnode.com'
  BLOG_HOST = ENV.fetch('BLOG_URL', 'https://blog.example.com').gsub(%r{^https?://}, '')
  CACHE_KEY = 'latest_blog_post'
  CACHE_DURATION = 15.minutes

  def self.fetch_latest
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_DURATION) do
      fetch_from_hashnode
    end
  end

  def self.fetch_from_hashnode
    uri = URI(HASHNODE_API)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 5

    request = Net::HTTP::Post.new(uri.path.empty? ? '/' : uri.path)
    request['Content-Type'] = 'application/json'
    request.body = {
      query: <<~GRAPHQL
        query {
          publication(host: "#{BLOG_HOST}") {
            posts(first: 1) {
              edges {
                node {
                  title
                  url
                  brief
                  publishedAt
                }
              }
            }
          }
        }
      GRAPHQL
    }.to_json

    response = http.request(request)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    post = data.dig('data', 'publication', 'posts', 'edges', 0, 'node')
    return nil unless post

    {
      title: post['title'],
      url: post['url'],
      description: truncate_text(post['brief']),
      published_at: Time.parse(post['publishedAt'])
    }
  rescue StandardError => e
    Rails.logger.warn "Failed to fetch blog from Hashnode: #{e.message}"
    nil
  end

  def self.truncate_text(text, length: 200)
    return nil if text.nil?
    ActionController::Base.helpers.truncate(text, length: length)
  end
end
