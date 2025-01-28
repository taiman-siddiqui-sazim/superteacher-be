module Api
  module V1
    module Users
      class TeachersController < ApplicationController
        def create_teacher_record(user, teacher_params)
          result = ::Teachers::CreateTeacher.call(user: user, teacher_params: teacher_params)

          if result.success?
            { status: :ok, teacher: result.teacher }
          else
            { status: :unprocessable_entity, errors: result.errors }
          end
        end

        private

        def teacher_params
          params.require(:teacher).permit(
            :major_subject, { subjects: [] }, :highest_education
          )
        end
      end
    end
  end
end
