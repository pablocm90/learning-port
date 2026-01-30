require 'rails_helper'

RSpec.describe BlogFeedService do
  describe '.fetch_latest' do
    it 'returns nil when feed is unavailable' do
      allow(URI).to receive(:open).and_raise(OpenURI::HTTPError.new('404', nil))

      result = BlogFeedService.fetch_latest

      expect(result).to be_nil
    end

    it 'parses RSS feed and returns latest post' do
      rss_content = <<~RSS
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <item>
              <title>Test Post</title>
              <link>https://blog.example.com/test</link>
              <description>This is a test post</description>
              <pubDate>Mon, 01 Jan 2024 00:00:00 +0000</pubDate>
            </item>
          </channel>
        </rss>
      RSS

      allow(URI).to receive(:open).and_return(StringIO.new(rss_content))

      result = BlogFeedService.fetch_latest

      expect(result[:title]).to eq('Test Post')
      expect(result[:url]).to eq('https://blog.example.com/test')
    end
  end
end
