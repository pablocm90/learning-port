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
    it 'validates presence of slug (when name is also blank so auto-generation cannot help)' do
      category = build(:podcast_category, name: nil, slug: nil)
      category.valid?
      expect(category.errors[:slug]).to include("can't be blank")
    end
    it { should validate_uniqueness_of(:slug) }
  end

  describe 'slug generation' do
    it 'generates slug from name before validation' do
      category = build(:podcast_category, name: 'Software Practices', slug: nil)
      category.valid?
      expect(category.slug).to eq('software-practices')
    end

    it 'does not overwrite an existing slug' do
      category = build(:podcast_category, name: 'Software Practices', slug: 'custom-slug')
      category.valid?
      expect(category.slug).to eq('custom-slug')
    end
  end

  describe '.find_by_slug!' do
    it 'finds a category by slug' do
      category = create(:podcast_category, slug: 'software-practices')
      expect(PodcastCategory.find_by_slug!('software-practices')).to eq(category)
    end

    it 'raises RecordNotFound for unknown slug' do
      expect { PodcastCategory.find_by_slug!('nonexistent') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'scopes' do
    it 'orders by position' do
      cat2 = create(:podcast_category, position: 2)
      cat1 = create(:podcast_category, position: 1)

      expect(PodcastCategory.ordered).to eq([cat1, cat2])
    end
  end
end
