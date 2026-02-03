Rails.application.routes.draw do
  devise_for :writers, skip: [:registrations]

  namespace :admin do
    get "/", to: "dashboard#index", as: :dashboard
    resources :categories, except: [:show]
    resources :learning_moments, except: [:index, :show]
    resources :podcast_episodes, except: [:index, :show]
  end

  root "pages#home"

  get "learning", to: "learning#index", as: :learning_portfolio
  get "podcast", to: "podcast_episodes#index", as: :podcast
  get "podcast/collections/:slug", to: "podcast_episodes#show", as: :podcast_collection
  get "blog/latest", to: "blog_posts#latest", as: :latest_blog_post
end
