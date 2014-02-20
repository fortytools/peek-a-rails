Peekarails::Engine.routes.draw do
  get 'dashboard' => 'dashboard#show', as: :dashboard

  root to: 'dashboard#show'
end
