module Classrooms
    class GetStudentClasses
      include Interactor

      USER_NOT_FOUND = "User not found".freeze
      STUDENT_NOT_FOUND = "Student record not found".freeze

      def call
        user = Users::User.find_by(id: context.user_id)
        unless user
          context.fail!(message: USER_NOT_FOUND, status: :not_found)
          return
        end

        student = Users::Student.find_by(user_id: user.id)
        unless student
          context.fail!(message: STUDENT_NOT_FOUND, status: :not_found)
          return
        end

        classrooms = Classrooms::Classroom.joins(:classroom_students)
                                          .where(classroom_students: { student_id: student.id })
                                          .select("classrooms.id, classrooms.title, classrooms.subject, classrooms.class_time, classrooms.days_of_week")

        context.classrooms = classrooms.map do |classroom|
          student_count = Classrooms::ClassroomStudent.where(classroom_id: classroom.id).count
          {
            id: classroom.id,
            title: classroom.title,
            subject: classroom.subject,
            class_time: classroom.class_time,
            days_of_week: classroom.days_of_week,
            student_count: student_count
          }
        end
      rescue => e
        context.fail!(message: e.message)
      end
    end
end
