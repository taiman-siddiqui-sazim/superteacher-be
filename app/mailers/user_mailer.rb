class UserMailer < ApplicationMailer
    default from: "no-reply <#{ENV['DEFAULT_FROM_EMAIL']}>"

    def otp_email(user, otp)
      @user = user
      @otp = otp
      mail(to: @user.email, subject: "Your OTP for Password Reset") do |format|
        format.html { render "otp_email" }
        format.text { render "otp_email" }
      end
    end

    def enroll_email(user, classroom)
      @user = user
      @classroom = classroom
      mail(to: @user.email, subject: "You have been enrolled in a new classroom") do |format|
        format.html { render "enroll_email" }
        format.text { render "enroll_email" }
      end
    end

    def classwork_email(user, classwork)
      @user = user
      @classwork = classwork

      resource_type = classwork.is_a?(Classwork::Assignment) ? "assignment" : "material"

      subject = "Classwork created in #{@classwork.classroom.title}"

      mail(to: @user.email, subject: subject) do |format|
        format.html { render "classwork_email" }
        format.text { render "classwork_email" }
      end
    end
end
