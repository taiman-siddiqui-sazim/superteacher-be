module Passwords
  class Forgot
    include Interactor

    def call
      user = User.find_by(email: context.email)
      if user
        otp = generate_otp
        user.update(otp: otp, otp_sent_at: Time.current)
        UserMailer.otp_email(user, otp).deliver_now
      end
      context.message = "If your email is registered, you will receive an OTP shortly"
    end

    private

    def generate_otp
      rand(100000..999999).to_s
    end
  end
end
