module Passwords
  class Reset
    include Interactor
    include Constants::UserConstants

    def call
      user = Users::User.find_by(email: context.email, otp: context.otp)
      if user && !user.otp_expired?
        user.password = context.password
        if user.valid?
          user.update(password: context.password, otp: nil, otp_sent_at: nil)
          context.message = PASSWORD_RESET_SUCCESSFUL
        else
          context.fail!(error: user.errors.full_messages.join(", "))
        end
      else
        context.fail!(error: OTP_INVALID)
      end
    end
  end
end
