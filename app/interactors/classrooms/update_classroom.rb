module Classrooms
    class UpdateClassroom
      include Interactor
      include Constants::ClassroomConstants

      def call
        teacher_id = context.teacher_id
        unless Users::User.exists?(id: teacher_id)
          context.fail!(message: TEACHER_NOT_FOUND, status: :not_found)
        end

      classroom = Classrooms::Classroom.find_by(id: context.classroom_id, teacher_id: teacher_id)

        if classroom.nil?
          context.fail!(message: CLASSROOM_NOT_FOUND, status: :not_found)
        elsif classroom.update(context.classroom_params)
          context.classroom = classroom
        else
          context.fail!(message: classroom.errors.full_messages, status: :unprocessable_entity)
        end
      end
    end
end
