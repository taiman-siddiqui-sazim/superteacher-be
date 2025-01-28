module Passwords
  class Reset
    include Interactor

    def call
      user = User.find_by(email: context.email, otp: context.otp)
      if user && !user.otp_expired?
        user.password = context.password
        if user.valid?
          user.update(password: context.password, otp: nil, otp_sent_at: nil)
          context.message = "Password reset successfully"
        else
          context.fail!(error: user.errors.full_messages.join(", "))
        end
      else
        context.fail!(error: "Invalid OTP or OTP expired")
      end
    end
  end
end
