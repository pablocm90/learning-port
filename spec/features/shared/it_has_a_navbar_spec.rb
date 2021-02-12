# frozen_string_literal: true

shared_examples_for 'it has a navbar' do
  it 'should have a navbar' do
    expect(page).to have_selector('.navbar')
  end
end
