Rails.application.routes.draw do
  use_doorkeeper

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      post "login", to: "sessions#create"
      get "users/me", to: "users#me"
      post "register/student", to: "users#create_student"
      post "register/teacher", to: "users#create_teacher"
    end
  end
end
