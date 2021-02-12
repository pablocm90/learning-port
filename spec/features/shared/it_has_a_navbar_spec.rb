# frozen_string_literal: true

shared_examples_for 'it has a navbar' do
  it 'should have a navbar' do
    expect(page).to have_selector('.navbar')
  end
  it 'should have a logo' do
    expect(page).to have_selector('.navbar__logo')
  end
  it 'should have space for some links' do
    expect(page).to have_selector('navbar__links')
  end
end
