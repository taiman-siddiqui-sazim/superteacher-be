class UserMailer < ApplicationMailer
    default from: ENV["DEFAULT_FROM_EMAIL"]

    def otp_email(user, otp)
      @user = user
      @otp = otp
      mail(to: @user.email, subject: "Your OTP for Password Reset") do |format|
        format.html { render "otp_email" }
        format.text { render "otp_email" }
      end
    end
end
