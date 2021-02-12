# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Visiting home', type: :feature do
  describe 'Visiting home page' do
    before(:example) do
      visit root_path
    end
    it 'should have a welcome message' do
      expect(page).to have_content("Welcome to Pablo's learning blog")
    end
    it 'should tell us the page title' do
      expect(page).to have_title('Learning Blog')
    end
    it 'should have an explanation' do
      expect(page).to have_selector('.page__content > .titled-paragraph > p.text-block')
    end
  end
end
