require 'rails_helper'

RSpec.describe LearningItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:status) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(learning: 0, practicing: 1, comfortable: 2, expert: 3) }
  end

  describe 'scopes' do
    it 'orders by position' do
      item2 = create(:learning_item, position: 2)
      item1 = create(:learning_item, position: 1)

      expect(LearningItem.ordered).to eq([item1, item2])
    end
  end
end
