require 'sidekiq/web'
Rails.application.routes.draw do
  # Auth routes
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    sessions: 'users/sessions'
  }

  # API routes
  scope 'api/v1', module: 'api/v1', as: 'api_v1', defaults: {format: :json} do
    # Auth routes
    post 'auth/sign_in', to: 'auth#sign_in'
    post 'auth/sign_up', to: 'auth#sign_up'
    # User routes
    get 'users/me', to: 'users#me'
    put 'users/change_password', to: 'users#change_password'
    # put 'users/update_profile', to: 'users#update_profile'
  end
  
  # Admin routes
  namespace :admin do
    resources :users do
      resources :addresses, except: [:index]
      resources :trips, except: [:index]
      resources :stripe_customers, except: [:index]
      resources :auth_tokens, except: [:index, :new, :create, :edit, :update] do
        member do
          post 'expire'
        end
      end
      resources :data_plans, except: [:index]
    end
    resources :sims
    resources :shipments
    resources :countries

    # Ensure only admins can view these pages
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end

    root 'dashboard#index', as: :admin_root
  end

  # Webhook routes
  namespace :webhooks do
    # Twilio webhooks
    namespace :twilio do
      post "voice/incoming", to: 'voice#incoming'
      post "voice/outgoing", to: 'voice#outgoing'
      post "sms/incoming", to: 'sms#incoming'
      post "sms/outgoing", to: 'sms#outgoing'

      post "sms/notification/incoming", to: 'sms#notification_response'

      # For network testing
      post "network_test/sms/incoming", to: 'network_test#incoming_sms'
    end
  end

  # Web app routes
  # Unauthenticated routes
  get 'pay/:user_token', to: 'web_app#add_payment_no_login'
  put 'add_payment_and_data', to: 'web_app#add_payment_and_data'
  # authenticated :user do
  # end

  root to: 'marketing#index'
end
