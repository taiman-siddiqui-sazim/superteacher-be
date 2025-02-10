module Classrooms
    class GetClassroomTeacher
      include Interactor
      include Constants::ClassroomConstants

      def call
        classroom = Classrooms::Classroom.find_by(id: context.classroom_id)
        unless classroom
          context.fail!(message: CLASSROOM_NOT_FOUND, status: :not_found)
        end

        teacher = Users::User.find_by(id: classroom.teacher_id)
        unless teacher
          context.fail!(message: TEACHER_NOT_FOUND, status: :not_found)
        end

        context.teacher = {
          id: teacher.id,
          first_name: teacher.first_name,
          last_name: teacher.last_name,
          email: teacher.email
        }
      rescue => e
        context.fail!(message: e.message)
      end
    end
end
