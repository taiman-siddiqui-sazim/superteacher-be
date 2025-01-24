module Users
    class CreateUser
      include Interactor

      PASSWORDS_DO_NOT_MATCH_ERROR = "Passwords do not match"
      USER_ALREADY_EXISTS_ERROR = "User already exists"
      INVALID_USER_TYPE_ERROR = "Invalid user type"

      def call
        user_params = context.user_params.slice(:first_name, :last_name, :gender, :email, :password, :confirm_password, :user_type)

        unless user_params[:password] == user_params[:confirm_password]
          context.fail!(errors: [ PASSWORDS_DO_NOT_MATCH_ERROR ])
          return
        end

        if User.exists?(email: user_params[:email])
          context.fail!(errors: [ USER_ALREADY_EXISTS_ERROR ])
          return
        end

        user_params[:gender] = user_params[:gender].downcase if user_params[:gender].present?
        user_params[:password_confirmation] = user_params.delete(:confirm_password)

        @user = User.new(user_params)

        if @user.save
          context.user = @user

          if user_params[:user_type] == "student"
            student_params = context.user_params.except(:first_name, :last_name, :gender, :email, :password, :confirm_password, :user_type)
            create_student_record(@user, student_params)
          end
        else
          context.fail!(errors: @user.errors.full_messages)
        end
      end

      private

      def create_student_record(user, student_params)
        student_creation_response = Api::V1::StudentsController.new.create_student_record(user, student_params)

        if student_creation_response[:status] == :ok
          context.student = student_creation_response[:student]
        else
          user.destroy
          context.fail!(errors: student_creation_response[:errors])
        end
      end
    end
end
