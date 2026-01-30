require 'rails_helper'

RSpec.describe Writer, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
  end

  describe 'attributes' do
    it 'has a bio' do
      writer = Writer.new(bio: 'Hello world')
      expect(writer.bio).to eq('Hello world')
    end
  end
end
