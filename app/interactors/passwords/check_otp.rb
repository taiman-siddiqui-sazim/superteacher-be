module Passwords
    class CheckOtp
      include Interactor
      include Constants::UserConstants

      def call
        user = Users::User.find_by(email: context.email, otp: context.otp)
        if user && !user.otp_expired?
          context.message = OTP_VALID
        else
          context.fail!(error: OTP_INVALID)
        end
      end
    end
end
