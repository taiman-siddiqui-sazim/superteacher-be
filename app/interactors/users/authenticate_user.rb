class Users::AuthenticateUser < BaseInteractor
  REQUIRED_PARAMS = %i[email password].freeze

  INVALID_CREDENTIALS = "Invalid credentials"

  delegate(*REQUIRED_PARAMS, to: :context)

  def call
    validate_params REQUIRED_PARAMS

    user = UserAuthenticationService.authenticate(email, password)

    if user && ((user.user_type == "student" && user.student.present?) || (user.user_type == "teacher" && user.teacher.present?))
      application = Doorkeeper::Application.find_by(uid: ENV["DOORKEEPER_CLIENT_ID"])
      if application
        token = Doorkeeper::AccessToken.create(
          resource_owner_id: user.id,
          application_id: application.id,
          expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
          scopes: ""
        )
        context.token = token.token
      else
        context.fail!(message: INVALID_CREDENTIALS)
      end
    else
      context.fail!(message: INVALID_CREDENTIALS)
    end
  end
end
