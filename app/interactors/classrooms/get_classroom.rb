module Classrooms
    class GetClassroom
      include Interactor
      include Constants::ClassroomConstants

      def call
        classroom = Classrooms::Classroom.find_by(id: context.classroom_id)

        unless classroom
          context.fail!(
            message: CLASSROOM_NOT_FOUND,
            status: :not_found
          )
        end

        context.classroom = classroom
      end
    end
end
