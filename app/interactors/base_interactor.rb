class BaseInteractor
    include Interactor

    SOMETHING_WENT_WRONG = "Something went wrong"
    UNAUTHORIZED = "Unauthorized"
    YOU_ARE_NOT_AUTHORIZED = "You are not authorized"

    def validate_params(required_params)
      missing_params = required_params.select { |param| context[param].nil? }

      context.fail!(
        message: "Missing params: #{missing_params.join(', ')}",
        status: :unprocessable_entity
      ) if missing_params.present?
    end
end
