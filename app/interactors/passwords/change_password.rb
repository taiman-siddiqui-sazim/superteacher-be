module Passwords
    class ChangePassword
      include Interactor
      include Constants::UserConstants

      def call
        user = Users::User.find_by(email: context.email)

        if user.nil?
          context.fail!(error: USER_NOT_FOUND)
        elsif context.current_password.blank? || context.new_password.blank?
          context.fail!(error: PASSWORD_BLANK)
        elsif !user.authenticate(context.current_password)
          context.fail!(error: INVALID_CURRENT_PASSWORD)
        else
          user.password = context.new_password

          if user.save
            context.message = PASSWORD_CHANGED
          else
            context.fail!(error: user.errors.full_messages.join(", "))
          end
        end
      end
    end
end
