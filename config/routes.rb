Rails.application.routes.draw do
  use_doorkeeper

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      namespace :users do
        # User routes
        get "me", to: "users#me"
        post "register/student", to: "users#create_student"
        post "register/teacher", to: "users#create_teacher"
      end

      # Authentication routes
      namespace :authorize do
        post "login", to: "sessions#create"
        post "passwords/forgot", to: "passwords#forgot_password"
        post "passwords/check_otp", to: "passwords#check_otp"
        post "passwords/reset", to: "passwords#reset_password"
      end

      post "classroom/teacher", to: "classrooms#create"
      get "classrooms", to: "classrooms#get_classrooms"
      put "classroom/:id", to: "classrooms#update_classroom"
      delete "classroom/:id", to: "classrooms#delete_classroom"
    end
  end
end
