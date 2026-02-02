require 'rails_helper'

RSpec.describe Category, type: :model do
  subject { build(:category) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:learning_moments).dependent(:destroy) }
  end

  describe 'scopes' do
    it 'orders by position' do
      cat2 = create(:category, position: 2)
      cat1 = create(:category, position: 1)

      expect(Category.ordered).to eq([cat1, cat2])
    end
  end

  describe '#weighted_score' do
    it 'returns sum of moment weights' do
      category = create(:category)
      create(:learning_moment, category: category, engagement_type: :consumed)   # 1
      create(:learning_moment, category: category, engagement_type: :applied)    # 3

      expect(category.weighted_score).to eq(4)
    end

    it 'returns 0 with no moments' do
      category = create(:category)
      expect(category.weighted_score).to eq(0)
    end
  end

  describe '#time_span_days' do
    it 'returns days between first and last moment' do
      category = create(:category)
      create(:learning_moment, category: category, occurred_at: 100.days.ago)
      create(:learning_moment, category: category, occurred_at: Date.today)

      expect(category.time_span_days).to eq(100)
    end

    it 'returns 0 with one moment' do
      category = create(:category)
      create(:learning_moment, category: category, occurred_at: Date.today)

      expect(category.time_span_days).to eq(0)
    end

    it 'returns 0 with no moments' do
      category = create(:category)
      expect(category.time_span_days).to eq(0)
    end
  end

  describe '#drip_depth' do
    it 'combines weighted score and time span' do
      category = create(:category)
      create(:learning_moment, category: category, engagement_type: :applied, occurred_at: 100.days.ago)
      create(:learning_moment, category: category, engagement_type: :consumed, occurred_at: Date.today)

      # weighted_score = 3 + 1 = 4
      # time_span_days = 100
      # drip_depth = 4 + (100 / 30.0) = 4 + 3.33 = 7.33
      expect(category.drip_depth).to be_within(0.1).of(7.33)
    end
  end

  describe '#engagement_types_present' do
    it 'returns array of engagement types that exist' do
      category = create(:category)
      create(:learning_moment, category: category, engagement_type: :consumed)
      create(:learning_moment, category: category, engagement_type: :applied)

      expect(category.engagement_types_present).to contain_exactly('consumed', 'applied')
    end
  end
end
