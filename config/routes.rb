Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount Ckeditor::Engine => '/ckeditor'

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations', confirmations: 'confirmations' }

  resources :designs do
    member do
      put 'like', to: 'designs#upvote'
    end
  end

  resources :products do
    resources :order_items, only: [:create, :destroy]
  end

  resources :articles do
    member do
      put 'like', to: 'articles#upvote'
    end
  end

  resources :addresses
  resources :orders, only: [:index, :show]

  root to: 'home#index'

  get 'users/:id', to: 'users#show', as: :user
  get 'users/:id/designs/', to: 'users#design', as: :user_designs
  get 'users/:id/orders/', to: 'users#order', as: :user_orders
  get 'users/:id/content/', to: 'users#content', as: :user_content
  get 'users/:id/address/', to: 'addresses#index', as: :user_address

  get '/users', to: 'users#index', as: :users_default
  get '/leaderboard', to: 'home#leaderboard', as: :leaderbord
  get '/competition', to: 'home#competition', as: :competition
  get '/contact', to: 'home#contact', as: :contact_us
  post '/contact', to: 'home#contact_us', as: :message
  get '/add-to-competition/:id', to: 'designs#add_to_competition'

  # These are static pages, not necessarily having a controller method for each:
  get '/themes', to: 'home#themes', as: :themes
  get '/guide', to: 'home#guide', as: :guide
  get '/about', to: 'home#about', as: :about
  get '/faq', to: 'home#faq', as: :faq
  get '/privacy', to: 'home#privacy', as: :privacy

  post '/checkout', to: 'orders#checkout', as: :checkout
  post 'orders/shipping/:id', to: 'orders#shipping', as: :shipping

  get 'robots.txt', to: 'home#robots', as: :robots

  get 'ck_editor_assets/*asset_name', to: 'ck_editor_assets#serve'

  # NOTE: this declaration must be the last one in routes.rb.
  match "*path", to: "application#handle_not_found", via: :all
end
