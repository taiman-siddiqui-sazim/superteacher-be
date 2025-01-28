Rails.application.routes.draw do
  use_doorkeeper

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      # Authentication routes
      post "login", to: "sessions#create"

      # User routes
      get "users/me", to: "users#me"
      post "register/student", to: "users#create_student"
      post "register/teacher", to: "users#create_teacher"

      # Password routes
      post "passwords/forgot", to: "passwords#forgot_password"
      post "passwords/check_otp", to: "passwords#check_otp"
      post "passwords/reset", to: "passwords#reset_password"
    end
  end
end
