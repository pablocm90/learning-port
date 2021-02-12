# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Writer, type: :model do
  it { is_expected.to have_attribute(:email) }
  it { is_expected.to have_attribute(:encrypted_password) }
end
