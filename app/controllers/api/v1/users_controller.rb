module Api
    module V1
      class UsersController < ApplicationController
        before_action :doorkeeper_authorize!
  
        USER_DATA_RETRIEVED = "User data retrieved successfully"
        USER_DATA_NOT_RETRIEVED = "User data could not be retrieved"

        def me
          user = current_user
          if user
            success_response(
              data: UserSerializer.new.serialize(user),
              message: USER_DATA_RETRIEVED
            )
          else
            error_response(
              message: [USER_DATA_NOT_RETRIEVED],
              status: :not_found,
              error: BaseInteractor::NOT_FOUND_ERROR
            )
          end
        end
  
        private
  
        def current_user
          @current_user ||= User.find_by(id: doorkeeper_token.resource_owner_id) if doorkeeper_token
        end
      end
    end
  end
