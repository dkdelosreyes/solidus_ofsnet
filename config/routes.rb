Rails.application.routes.draw do
  Healthcheck.routes(self)
  filter :locale
  # This line mounts Solidus's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Solidus relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/'
  mount SolidusPaypalCommercePlatform::Engine, at: '/solidus_paypal_commerce_platform'

  get '/country', to: 'spree/home#country'
  post '/country', to: 'spree/home#country'

  get 'live', action: :index, controller: 'lives'
  get 'contactus', action: :new, controller: 'contact_forms'

  namespace :telr do
    post '/callbacks/transaction', to: 'callbacks#transaction', as: :transaction
    post '/callbacks/advice', to: 'callbacks#advice_service', as: :advice_service
    get '/pay/:id', to: 'requests#pay', as: :pay
  end

  get '/404', to: 'errors#not_found'
  get '/422', to: 'errors#unacceptable'
  get '/500', to: 'errors#internal_error'

  devise_scope :spree_user do
    get '/auth/google_oauth2/callback', to: 'spree/admin/omniauth_callbacks#google_oauth'
  end

  namespace :services do
    namespace :facebook do
      get 'webhooks', to: 'webhooks#verify'
      post 'webhooks', to: 'webhooks#interact'
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

# Backend routes
Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :facebook_pages do
      get :debug_token
      get :sync_videos
    end

    resources :facebook_page_live, only: %w(destroy)
  end
end
