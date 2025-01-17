module Api
  module V1
    class SessionsController < ApplicationController
      AUTHENTICATION_SUCCESSFUL = "Authentication successful"
      UNAUTHORIZED = "Unauthorized"

      def create
        result = Users::AuthenticateUser.call(email: params[:email], password: params[:password])

        if result.success?
          user = result.user
          success_response(
            data: {
              accessToken: result.token,
              user: UserSerializer.new.serialize(user)
            },
            message: AUTHENTICATION_SUCCESSFUL
          )
        else
          error_response(
            message: [result.message],
            status: :unauthorized,
            error: UNAUTHORIZED
          )
        end
      end
    end
  end
end
