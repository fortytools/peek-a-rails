Peekarails::Engine.routes.draw do
  resources :requests, only: [:index]
  resource :system, only: [:show]

  root to: 'requests#index'
end
