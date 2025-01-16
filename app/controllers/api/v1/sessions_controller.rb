module Api
  module V1
    class SessionsController < ApplicationController
      def create
        result = Users::AuthenticateUser.call(email: params[:email], password: params[:password])

        if result.success?
          user = result.user
          success_response(
            data: {
              accessToken: result.token,
              user: {
                id: user.id,
                first_name: user.first_name,
                last_name: user.last_name,
                gender: user.gender,
                email: user.email,
                user_type: user.user_type.upcase
              }
            },
            message: BaseInteractor::AUTHENTICATION_SUCCESSFUL
          )
        else
          error_response(
            message: result.message,
            status: :unauthorized,
            error: BaseInteractor::UNAUTHORIZED
          )
        end
      end
    end
  end
end
