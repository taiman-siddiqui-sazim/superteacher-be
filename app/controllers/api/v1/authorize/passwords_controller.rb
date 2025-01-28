module Api
  module V1
    module Authorize
      class PasswordsController < ApplicationController
        def forgot_password
          result = ::Passwords::Forgot.call(email: params[:email])
          if result.success?
            render json: { message: result.message }, status: :ok
          else
            render json: { error: result.error }, status: :unprocessable_entity
          end
        end

        def check_otp
          result = ::Passwords::CheckOtp.call(email: params[:email], otp: params[:otp])
          if result.success?
            render json: { message: result.message }, status: :ok
          else
            render json: { error: result.error }, status: :unprocessable_entity
          end
        end

        def reset_password
          result = ::Passwords::Reset.call(email: params[:email], otp: params[:otp], password: params[:password])
          if result.success?
            render json: { message: result.message }, status: :ok
          else
            render json: { error: result.error }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
