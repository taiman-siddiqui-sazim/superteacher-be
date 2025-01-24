module Teachers
    class CreateTeacher
      include Interactor

      def call
        user = context.user
        teacher_params = transform_teacher_params(context.teacher_params)

        @teacher = user.build_teacher(teacher_params)

        if @teacher.save
          context.teacher = @teacher
        else
          context.fail!(errors: @teacher.errors.full_messages)
        end
      end

      private

      def transform_teacher_params(params)
        if params[:highest_education].present?
          params[:highest_education] = params[:highest_education].gsub("'", "").downcase
        end
        params
      end
    end
end
