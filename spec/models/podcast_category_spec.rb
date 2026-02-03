require 'rails_helper'

RSpec.describe PodcastCategory, type: :model do
  subject { build(:podcast_category) }

  describe 'associations' do
    it { should have_many(:podcast_episode_categories).dependent(:destroy) }
    it { should have_many(:podcast_episodes).through(:podcast_episode_categories) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'scopes' do
    it 'orders by position' do
      cat2 = create(:podcast_category, position: 2)
      cat1 = create(:podcast_category, position: 1)

      expect(PodcastCategory.ordered).to eq([cat1, cat2])
    end
  end
end
