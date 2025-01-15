class ApplicationController < ActionController::API
    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      render json: { error: BaseInteractor::NOT_AUTHORIZED_MESSAGE }, status: :forbidden
    end
end
