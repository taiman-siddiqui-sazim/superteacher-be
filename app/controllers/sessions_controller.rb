require "jwt"

class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      if (user.user_type == "student" && user.student) || (user.user_type == "teacher" && user.teacher)
        token = encode_token({ user_id: user.id })
        render json: { token: token }, status: :ok
      else
        render json: { error: "Record does not exist" }, status: :unauthorized
      end
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def encode_token(payload)
    JWT.encode(payload, ENV["JWT_SECRET_KEY"])
  end
end
