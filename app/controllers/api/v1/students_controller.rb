module Api
    module V1
      class StudentsController < ApplicationController
        def create_student_record(user, student_params)
          result = Students::CreateStudent.call(user: user, student_params: student_params)

          if result.success?
            { status: :ok, student: result.student }
          else
            { status: :unprocessable_entity, errors: result.errors }
          end
        end

        private

        def student_params
          params.require(:student).permit(
            :phone, :address, :education_level, :medium, :year, :degree_type, :degree_name, :semester_year
          )
        end
      end
    end
end
