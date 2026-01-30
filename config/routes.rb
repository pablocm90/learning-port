Rails.application.routes.draw do
  devise_for :writers, skip: [:registrations]

  root "pages#home"
end
