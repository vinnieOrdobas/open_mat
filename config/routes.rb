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
      get :profile, to: "profile#show"

      # Academy Management
      resources :academies, only: %i[create show update]

      resources :amenities, only: %i[index]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
