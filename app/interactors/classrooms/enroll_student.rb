module Classrooms
    class EnrollStudent
      include Interactor
      
      STUDENT_ENROLLMENT_FAIL = "Student enrollment failed".freeze
  
      def call
        user = Users::User.find_by(id: context.user_id, email: context.email)
        unless user
          context.fail!(message: "User not found", status: :not_found, error: ClassroomConstants::STUDENT_ENROLLMENT_FAIL)
        end
  
        student = Users::Student.find_by(user_id: user.id)
        unless student
          context.fail!(message: "Student record not found", status: :not_found, error: ClassroomConstants::STUDENT_ENROLLMENT_FAIL)
        end
  
        classroom_student = Classrooms::ClassroomStudent.new(classroom_id: context.classroom_id, student_id: student.id, enroll_date: Date.today)
  
        if classroom_student.save
          UserMailer.enroll_email(user, classroom_student.classroom).deliver_now
          context.classroom_student = classroom_student
        else
          context.fail!(message: classroom_student.errors.full_messages, status: :unprocessable_entity, error: ClassroomConstants::STUDENT_ENROLLMENT_FAIL)
        end
      end
    end
  end
