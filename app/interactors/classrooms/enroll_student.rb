module Classrooms
  class EnrollStudent
    include Interactor
    include Constants::ClassroomConstants

    def call
      user = Users::User.find_by(id: context.user_id, email: context.email)
      unless user
        context.fail!(message: USER_NOT_FOUND, status: :not_found)
      end

      student = Users::Student.find_by(user_id: user.id)

      classroom_student = Classrooms::ClassroomStudent.new(
        classroom_id: context.classroom_id,
        student_id: student.id,
        enroll_date: Date.today
      )

      if classroom_student.save
        UserMailer.enroll_email(user, classroom_student.classroom).deliver_now
        context.classroom_student = classroom_student
      else
        context.fail!(
          message: classroom_student.errors.full_messages,
          status: :unprocessable_entity
        )
      end
    end
  end
end
