module Classrooms
    class UnenrollStudent
      include Interactor

      STUDENT_UNENROLLMENT_SUCCESS = "Student unenrolled successfully".freeze
      STUDENT_UNENROLLMENT_FAIL = "Student unenrollment failed".freeze

      def call
        user = Users::User.find_by(id: context.user_id)
        unless user
          context.fail!(message: "User not found", status: :not_found, error: STUDENT_UNENROLLMENT_FAIL)
        end

        student = Users::Student.find_by(user_id: user.id)
        unless student
          context.fail!(message: "Student record not found", status: :not_found, error: STUDENT_UNENROLLMENT_FAIL)
        end

        classroom_student = Classrooms::ClassroomStudent.find_by(classroom_id: context.classroom_id, student_id: student.id)
        unless classroom_student
          context.fail!(message: "Enrollment record not found", status: :not_found, error: STUDENT_UNENROLLMENT_FAIL)
        end

        if classroom_student.destroy
          context.message = STUDENT_UNENROLLMENT_SUCCESS
        else
          context.fail!(message: "Failed to unenroll student", status: :unprocessable_entity, error: STUDENT_UNENROLLMENT_FAIL)
        end
      rescue => e
        context.fail!(message: e.message)
      end
    end
end
