# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :writers
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'static_pages#home'

  resources :writers, only: [] do
    member do 
      get :dashboard
    end
    resources :learning_stocks, only: [:new, :create, :update, :edit]
  end

  
end
