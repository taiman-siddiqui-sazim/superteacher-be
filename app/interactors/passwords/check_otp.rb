module Passwords
    class CheckOtp
      include Interactor

      def call
        user = User.find_by(email: context.email, otp: context.otp)
        if user && !user.otp_expired?
          context.message = "OTP is valid"
        else
          context.fail!(error: "Invalid OTP or OTP expired")
        end
      end
    end
end
