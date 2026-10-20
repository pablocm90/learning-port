require "rails_helper"

RSpec.describe BlogFeedService do
  describe ".fetch_latest" do
    def with_feed_url(url)
      original = ENV["BLOG_RSS_URL"]
      ENV["BLOG_RSS_URL"] = url
      yield
    ensure
      ENV["BLOG_RSS_URL"] = original
    end

    def rss(items)
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0"><channel>#{items.join}</channel></rss>
      XML
    end

    def item(title:, slug:, published:)
      <<~XML
        <item>
          <title><![CDATA[#{title}]]></title>
          <description><![CDATA[About #{title}]]></description>
          <link>https://blog.example.com/#{slug}</link>
          <pubDate>#{published}</pubDate>
        </item>
      XML
    end

    it "returns the newest post in the RSS feed" do
      stub_request(:get, "https://feed.test/rss.xml").to_return(body: rss([
        item(title: "The wrong unit", slug: "wrong-unit", published: "Wed, 19 Aug 2026 16:11:12 GMT"),
        item(title: "Rant code", slug: "rant-code", published: "Fri, 17 Apr 2026 10:14:46 GMT")
      ]))

      result = with_feed_url("https://feed.test/rss.xml") { BlogFeedService.fetch_latest }

      expect(result).to eq(
        title: "The wrong unit",
        url: "https://blog.example.com/wrong-unit",
        description: "About The wrong unit",
        published_at: Time.utc(2026, 8, 19, 16, 11, 12)
      )
    end

    {
      "is unreachable" => ->(stub) { stub.to_timeout },
      "serves an error page" => ->(stub) { stub.to_return(status: 503, body: "<html><body>Service Unavailable</body></html>") }
    }.each do |reason, respond|
      it "returns nil when the feed #{reason}" do
        respond.call(stub_request(:get, "https://feed.test/rss.xml"))

        result = with_feed_url("https://feed.test/rss.xml") { BlogFeedService.fetch_latest }

        expect(result).to be_nil
      end
    end

    it "returns nil when the feed has no posts" do
      stub_request(:get, "https://feed.test/rss.xml").to_return(body: rss([]))

      result = with_feed_url("https://feed.test/rss.xml") { BlogFeedService.fetch_latest }

      expect(result).to be_nil
    end
  end
end
