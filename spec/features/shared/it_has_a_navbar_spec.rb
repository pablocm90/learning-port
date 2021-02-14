# frozen_string_literal: true

require_relative '../helpers/responsivity'

RSpec.configure do |config|
  config.include Responsivity
end

shared_examples_for 'it has a navbar' do
  it 'should have a navbar' do
    expect(page).to have_selector('.navbar')
  end
  it 'should have a logo' do
    expect(page).to have_selector('.navbar__logo')
  end
  context 'with links' do
    context 'while on a big screen' do
      it 'should have space for some links' do
        expect(page).to have_selector('.navbar__links')
      end
      it 'should have link for sign_in' do
        if page.current_path == new_writer_session_path
          expect(page).not_to have_selector('a.link.navbar__link', text: 'Sign in')
          expect(page).to have_selector('p.link.navbar__link.navbar__link--current', text: 'Sign in')
        else
          within('.navbar__links') do
            click_link('Sign in')
            expect(page.current_path).to eq(new_writer_session_path)
          end
        end
      end
      it 'should have link for home' do
        if page.current_path == root_path
          expect(page).not_to have_selector('a.link.navbar__link', text: 'Home')
          expect(page).to have_selector('p.link.navbar__link.navbar__link--current', text: 'Home')
        else
          within('.navbar__links') do
            click_link('Home')
            expect(page.current_path).to eq(root_path)
          end
        end
      end
    end
    context 'when smaller than a tablet' do
      before(:context) do
        Capybara.current_driver = :selenium
        resize_window_to_tablet
      end
      after(:context) do
        Capybara.use_default_driver
        resize_window_default
      end
      it 'should not have the links' do
        expect(page).not_to have_selector('.navbar__links')
      end
      it 'should have a selector to open a link pane' do
        expect(page).to have_selector('.navbar__pane-toggler')
      end
      context 'when clicking on the toggler' do
        before(:context) do
          Capybara.current_driver = :selenium
          resize_window_to_tablet
        end
        after(:context) do
          Capybara.use_default_driver
          resize_window_default
        end
        before(:example) do
          find('#navbar__pane-toggler').click
        end
        it 'should flip between a cross and a burger' do
          expect(page).not_to have_css('.fas.fa-hamburger')
          expect(page).to have_css('.far.fa-times-circle')

          find('#navbar__pane-toggler').click

          expect(page).not_to have_css('.far.fa-times-circle')
          expect(page).to have_css('.fas.fa-hamburger')
        end
        it 'should toggle a panel with links' do
          expect(page).to have_css('.navbar__mobile-link-pane')
        end
      end
    end
  end
end
