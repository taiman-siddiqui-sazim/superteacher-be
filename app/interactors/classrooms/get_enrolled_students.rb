module Classrooms
  class GetEnrolledStudents
    include Interactor
    include Constants::ClassroomConstants

    def call
      classroom_id = context.classroom_id
      students = Users::Student.joins(:user)
                               .joins(:classroom_students)
                               .where(classroom_students: { classroom_id: classroom_id })
                               .select("users.id, users.email, users.first_name, users.last_name")

      if students.any?
        context.students = students
      else
        context.fail!(message: NO_STUDENTS_FOUND, status: :not_found)
      end
    rescue => e
      context.fail!(message: e.message)
    end
  end
end
