Rails.application.routes.draw do
  devise_for :writers, skip: [:registrations]

  namespace :admin do
    get "/", to: "dashboard#index", as: :dashboard
    resources :learning_items, except: [:index, :show]
    resources :podcast_episodes, except: [:index, :show]
  end

  root "pages#home"

  get "learning", to: "learning_items#index", as: :learning_portfolio
  resources :learning_items, only: [:show]
  get "podcast", to: "podcast_episodes#index", as: :podcast
  get "blog/latest", to: "blog_posts#latest", as: :latest_blog_post
end
