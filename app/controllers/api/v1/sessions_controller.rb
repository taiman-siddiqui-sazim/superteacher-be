module Api
  module V1
    class SessionsController < ApplicationController
      def create
        result = Users::AuthenticateUser.call(email: params[:email], password: params[:password])

        if result.success?
          render json: { token: result.token }, status: :ok
        else
          render json: { error: result.message }, status: :unauthorized
        end
      end
    end
  end
end
