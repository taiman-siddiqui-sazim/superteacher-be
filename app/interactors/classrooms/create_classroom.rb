module Classrooms
    class CreateClassroom
      include Interactor
      include Constants::ClassroomConstants

      def call
        teacher_id = context.teacher_id
        unless Users::User.exists?(id: teacher_id)
          context.fail!(message: TEACHER_NOT_FOUND, status: :not_found)
        end

       classroom = Classrooms::Classroom.new(context.classroom_params.merge(teacher_id: teacher_id))

       if classroom.save
        context.classroom = classroom
       else
        context.fail!(message: classroom.errors.full_messages, status: :unprocessable_entity)
       end
    end
    end
end
