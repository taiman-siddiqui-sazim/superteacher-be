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

     # Classroom routes
     namespace :classrooms do
        get ":classroom_id/unenrolled_students", to: "classroom_students#unenrolled_students"
        post ":classroom_id/enroll_student", to: "classroom_students#enroll_student"
        get ":classroom_id/students", to: "classroom_students#students_in_classroom"
        delete ":classroom_id/unenroll_student/:user_id", to: "classroom_students#unenroll_student"
        get "student_classrooms", to: "classroom_students#get_classrooms_for_student"

        post "", to: "classrooms#create"
        get "", to: "classrooms#get_classrooms_for_teacher"
        put ":id", to: "classrooms#update_classroom"
        delete ":id", to: "classrooms#delete_classroom"
        get ":classroom_id/teacher", to: "classrooms#get_teacher_by_classroom_id"
      end

      # Classwork routes
      namespace :classwork do
        post "file-uploads", to: "file_uploads#create_url"
        post "assignments", to: "assignments#create_assignment"
        get "assignments/:classroom_id", to: "assignments#get_assignments_by_classroom"
        post "assignments/:id/update_file", to: "assignments#update_file"
        put "assignments/:id", to: "assignments#update_assignment_fields"
        delete "assignments/:id", to: "assignments#delete_assignment"
      end
    end
  end
end
