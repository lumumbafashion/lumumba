Rails.application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks", registrations: 'registrations', confirmations: "confirmations"}
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :designs
  resources :articles
  root to: "home#index"
  get 'users/:id', to: 'users#show', as: :user
end
