require 'rails_helper'

RSpec.describe BlogFeedService do
  describe '.fetch_latest' do
    let(:http_double) { instance_double(Net::HTTP) }

    before do
      allow(Net::HTTP).to receive(:new).and_return(http_double)
      allow(http_double).to receive(:use_ssl=)
      allow(http_double).to receive(:read_timeout=)
      Rails.cache.clear
    end

    it 'returns nil when API request fails' do
      allow(http_double).to receive(:request).and_raise(StandardError.new('Connection failed'))

      result = BlogFeedService.fetch_latest

      expect(result).to be_nil
    end

    it 'parses Hashnode GraphQL response and returns latest post' do
      api_response = {
        data: {
          publication: {
            posts: {
              edges: [
                {
                  node: {
                    title: 'Test Post',
                    url: 'https://blog.example.com/test',
                    brief: 'This is a test post',
                    publishedAt: '2024-01-01T00:00:00.000Z'
                  }
                }
              ]
            }
          }
        }
      }.to_json

      success_response = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(success_response).to receive(:body).and_return(api_response)
      allow(http_double).to receive(:request).and_return(success_response)

      result = BlogFeedService.fetch_latest

      expect(result[:title]).to eq('Test Post')
      expect(result[:url]).to eq('https://blog.example.com/test')
      expect(result[:description]).to eq('This is a test post')
    end

    it 'returns nil when publication has no posts' do
      api_response = {
        data: {
          publication: {
            posts: {
              edges: []
            }
          }
        }
      }.to_json

      success_response = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(success_response).to receive(:body).and_return(api_response)
      allow(http_double).to receive(:request).and_return(success_response)

      result = BlogFeedService.fetch_latest

      expect(result).to be_nil
    end
  end
end
