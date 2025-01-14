module Api
  module V1
    class SessionsController < ApplicationController
      def create
        user = UserAuthenticationService.authenticate(params[:email], params[:password])

        if user.nil?
          render json: { error: "Invalid email or password" }, status: :unauthorized
          return
        end

        if (user.user_type == "student" && user.student.present?) || (user.user_type == "teacher" && user.teacher.present?)
          application = Doorkeeper::Application.find_by(uid: ENV["DEFAULT_CLIENT_ID"])
          if application
            token = Doorkeeper::AccessToken.create(
              resource_owner_id: user.id,
              application_id: application.id,
              expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
              scopes: ""
            )
            render json: { token: token.token }, status: :ok
          else
            render json: { error: "Default application not found" }, status: :unauthorized
          end
        else
          render json: { error: "Record does not exist" }, status: :unauthorized
        end
      end
    end
  end
end
