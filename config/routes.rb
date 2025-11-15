Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # API namespace
  namespace :api do
    namespace :v1 do
      # User registration and authentication
      resources :users, only: %i[create]
      post :login, to: "sessions#create"

      resource :profile, only: %i[show update], controller: "profile"

      # Academy Management
      resources :academies, only: %i[index create show update] do
        resources :academy_amenities, only: %i[create destroy], controller: "academy_amenities", path: "amenities"
        resources :passes, only: %i[create update destroy]
        resources :reviews, only: %i[create update destroy]

        resources :order_line_items, only: %i[index], controller: "academy_order_line_items"
        resources :class_schedules, only: %i[index create destroy] do
          resources :bookings, only: %i[create]
        end
      end

      resources :amenities, only: %i[index]

      resources :order_line_items, only: %i[update], controller: "order_line_items"

      resources :orders, only: %i[create index] do
        resource :confirmation, only: %i[create], controller: "order_confirmations"
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
