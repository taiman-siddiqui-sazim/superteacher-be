class UserMailerPreview < ActionMailer::Preview
    def otp_email
      user = User.first || User.new(email: "test@example.com", first_name: "Test")
      otp = "123456"
      UserMailer.otp_email(user, otp)
    end
end
