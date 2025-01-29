module Users
  class CreateUser
    include Interactor

    PASSWORDS_DO_NOT_MATCH_ERROR = "Passwords do not match"
    USER_ALREADY_EXISTS_ERROR = "User already exists"
    INVALID_USER_TYPE_ERROR = "Invalid user type"

    def call
      user_params = permit_user_params(context.user_params)

      unless user_params[:password] == user_params[:confirm_password]
        context.fail!(errors: [ PASSWORDS_DO_NOT_MATCH_ERROR ])
        return
      end

      if Users::User.exists?(email: user_params[:email])
        context.fail!(errors: [ USER_ALREADY_EXISTS_ERROR ])
        return
      end

      user_params[:gender] = user_params[:gender].downcase if user_params[:gender].present?
      user_params.delete(:confirm_password)

      @user = Users::User.new(user_params)

      if @user.save
        context.user = @user

        if user_params[:user_type] == "student"
          student_params = permit_student_params(context.user_params)
          create_student_record(@user, student_params)
        elsif user_params[:user_type] == "teacher"
          teacher_params = permit_teacher_params(context.user_params)
          create_teacher_record(@user, teacher_params)
        else
          @user.destroy
          context.fail!(errors: [ INVALID_USER_TYPE_ERROR ])
        end
      else
        context.fail!(errors: @user.errors.full_messages)
      end
    end

    private

    def permit_user_params(params)
      params.permit(:first_name, :last_name, :gender, :email, :password, :confirm_password, :user_type)
    end

    def permit_student_params(params)
      params.permit(:phone, :address, :education_level, :medium, :year, :degree_type, :degree_name, :semester_year)
    end

    def permit_teacher_params(params)
      params.permit(:major_subject, { subjects: [] }, :highest_education)
    end

    def create_student_record(user, student_params)
      student_creation_response = Api::V1::Users::StudentsController.new.create_student_record(user, student_params)

      if student_creation_response[:status] == :ok
        context.student = student_creation_response[:student]
      else
        user.destroy
        context.fail!(errors: student_creation_response[:errors])
      end
    end

    def create_teacher_record(user, teacher_params)
      teacher_creation_response = Api::V1::Users::TeachersController.new.create_teacher_record(user, teacher_params)

      if teacher_creation_response[:status] == :ok
        context.teacher = teacher_creation_response[:teacher]
      else
        user.destroy
        context.fail!(errors: teacher_creation_response[:errors])
      end
    end
  end
end
