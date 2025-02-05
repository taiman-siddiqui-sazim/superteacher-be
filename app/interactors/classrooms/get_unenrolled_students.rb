module Classrooms
  class GetUnenrolledStudents
    include Interactor

    def call
      classroom_id = context.classroom_id
      enrolled_students = Classrooms::ClassroomStudent.where(classroom_id: classroom_id).pluck(:student_id)
      unenrolled_students = Users::Student.joins(:user)
                                          .where.not(id: enrolled_students)
                                          .select('users.id, users.first_name, users.last_name, users.email')

      context.unenrolled_students = unenrolled_students
    rescue => e
      context.fail!(message: e.message)
    end
  end
end
