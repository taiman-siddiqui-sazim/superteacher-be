module Classrooms
    class UnenrollStudent
      include Interactor
      include Constants::ClassroomConstants

      def call
        user = Users::User.find_by(id: context.user_id)
        unless user
          context.fail!(message: USER_NOT_FOUND, status: :not_found)
        end

        student = Users::Student.find_by(user_id: user.id)

        classroom_student = Classrooms::ClassroomStudent.find_by(classroom_id: context.classroom_id, student_id: student.id)
        unless classroom_student
          context.fail!(message: "Enrollment record not found", status: :not_found)
        end

        if classroom_student.destroy
          context.message = STUDENT_UNENROLLMENT_SUCCESS
        else
          context.fail!(message: STUDENT_UNENROLLMENT_FAIL, status: :unprocessable_entity)
        end
      rescue => e
        context.fail!(message: e.message)
      end
    end
end
