module Students
  class CreateStudent
    include Interactor

    def call
      user = context.user
      student_params = transform_student_params(context.student_params)

      @student = user.build_student(student_params)

      if @student.save
        context.student = @student
      else
        context.fail!(errors: @student.errors.full_messages)
      end
    end

    private

    def transform_student_params(params)
      params[:education_level] = params[:education_level].downcase if params[:education_level].present?
      params[:medium] = params[:medium].downcase if params[:medium].present?
      if params[:degree_type].present?
        params[:degree_type] = params[:degree_type].gsub("'", "").downcase
      end
      params
    end
  end
end
