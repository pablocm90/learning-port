Rails.application.routes.draw do
  devise_for :writers, skip: [:registrations]

  root "pages#home"

  get "learning", to: "learning_items#index", as: :learning_portfolio
  resources :learning_items, only: [:show]
  get "podcast", to: "podcast_episodes#index", as: :podcast
end
