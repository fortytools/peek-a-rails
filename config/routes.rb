Peekarails::Engine.routes.draw do
  resources :requests, only: [:index]
  resource :system, only: [:show]
  resource :database, only: [:show]

  root to: 'requests#index'
end
