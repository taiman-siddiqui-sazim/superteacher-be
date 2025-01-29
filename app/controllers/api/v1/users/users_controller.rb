module Api
  module V1
    module Users
      class UsersController < ApplicationController
        include ResponseHelper
        before_action :doorkeeper_authorize!, except: [ :create_student, :create_teacher ]

        USER_DATA_RETRIEVED = "User data retrieved successfully"
        USER_DATA_NOT_RETRIEVED = "User data could not be retrieved"
        USER_REGISTRATION_SUCCESSFUL = "User registered successfully"
        USER_REGISTRATION_FAILED = "User registration failed"

        def me
          user = current_user
          if user
            success_response(
              data: ::UserSerializer.new.serialize(user),
              message: USER_DATA_RETRIEVED
            )
          else
            error_response(
              message: [ USER_DATA_NOT_RETRIEVED ],
              status: :not_found,
              error: ::BaseInteractor::NOT_FOUND_ERROR
            )
          end
        end

        def create_student
          result = ::Users::CreateUser.call(user_params: student_registration_params)

          if result.success?
            handle_authentication(result.user.email, student_registration_params[:password])
          else
            error_response(
              message: result.errors,
              status: :unprocessable_entity,
              error: USER_REGISTRATION_FAILED
            )
          end
        end

        def create_teacher
          result = ::Teachers::VerifyTeacher.call(email: params[:email], unique_code: params[:unique_code], user_params: params)

          if result.success?
            user_params = result.user_params.merge(user_type: "teacher")
            create_user_result = ::Users::CreateUser.call(user_params: user_params)

            if create_user_result.success?
              handle_authentication(create_user_result.user.email, user_params[:password])
            else
              error_response(
                message: create_user_result.errors,
                status: :unprocessable_entity,
                error: USER_REGISTRATION_FAILED
              )
            end
          else
            error_response(
              message: result.message,
              status: result.status,
              error: USER_REGISTRATION_FAILED
            )
          end
        end

        private

        def handle_authentication(email, password)
          auth_result = ::Users::AuthenticateUser.call(email: email, password: password)
          if auth_result.success?
            success_response(
              data: {
                user: ::UserSerializer.new.serialize(auth_result.user),
                accessToken: auth_result.token
              },
              message: USER_REGISTRATION_SUCCESSFUL,
              status: :created
            )
          else
            error_response(
              message: auth_result.message,
              status: :unprocessable_entity,
              error: USER_REGISTRATION_FAILED
            )
          end
        end

        def student_registration_params
          params.require(:user).permit(
            :first_name, :last_name, :gender, :email, :password, :confirm_password,
            :phone, :address, :education_level, :medium, :class, :degree_type, :degree_name, :semester_year
          ).merge(user_type: "student").tap do |student_params|
            student_params[:year] = student_params.delete(:class) if student_params[:class]
          end
        end

        def current_user
          @current_user ||= ::Users::User.find_by(id: doorkeeper_token.resource_owner_id) if doorkeeper_token
        end
      end
    end
  end
end
