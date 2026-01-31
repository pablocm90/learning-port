require 'rails_helper'

RSpec.describe LearningMoment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:engagement_type) }
    it { should validate_presence_of(:occurred_at) }
  end

  describe 'associations' do
    it { should belong_to(:category) }
  end

  describe 'enums' do
    it { should define_enum_for(:engagement_type).with_values(consumed: 0, experimented: 1, applied: 2, shared: 3) }
  end

  describe '#weight' do
    it 'returns 1 for consumed' do
      moment = build(:learning_moment, engagement_type: :consumed)
      expect(moment.weight).to eq(1)
    end

    it 'returns 2 for experimented' do
      moment = build(:learning_moment, engagement_type: :experimented)
      expect(moment.weight).to eq(2)
    end

    it 'returns 3 for applied' do
      moment = build(:learning_moment, engagement_type: :applied)
      expect(moment.weight).to eq(3)
    end

    it 'returns 4 for shared' do
      moment = build(:learning_moment, engagement_type: :shared)
      expect(moment.weight).to eq(4)
    end
  end

  describe 'scopes' do
    it 'orders chronologically (oldest first)' do
      new_moment = create(:learning_moment, occurred_at: 1.day.ago)
      old_moment = create(:learning_moment, occurred_at: 1.year.ago)

      expect(LearningMoment.chronological).to eq([old_moment, new_moment])
    end
  end
end
