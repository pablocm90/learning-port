require 'rails_helper'

RSpec.describe PodcastEpisode, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:episode_number) }
    it { should validate_uniqueness_of(:episode_number) }
  end

  describe 'scopes' do
    it 'orders by newest first' do
      old = create(:podcast_episode, published_at: 1.week.ago)
      new_ep = create(:podcast_episode, published_at: 1.day.ago)

      expect(PodcastEpisode.newest_first).to eq([new_ep, old])
    end
  end
end
