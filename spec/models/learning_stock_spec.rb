# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LearningStock, type: :model do
  it { is_expected.to have_attribute :name }
  it { is_expected.to have_attribute :icon }
  it { is_expected.to have_attribute :desired_weight }
  it { is_expected.to have_attribute :time_spent }
  it { is_expected.to have_attribute :magnitude }
end
