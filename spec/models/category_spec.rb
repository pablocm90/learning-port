require 'rails_helper'

RSpec.describe Category, type: :model do
  subject { build(:category) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    # Note: This test will pass once LearningMoment model is created in Task 2
    xit { should have_many(:learning_moments).dependent(:destroy) }
  end

  describe 'scopes' do
    it 'orders by position' do
      cat2 = create(:category, position: 2)
      cat1 = create(:category, position: 1)

      expect(Category.ordered).to eq([cat1, cat2])
    end
  end
end
