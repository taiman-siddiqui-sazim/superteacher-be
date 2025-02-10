module Classrooms
  class GetClassrooms
    include Interactor
    include Constants::ClassroomConstants

    def call
      teacher_id = context.teacher_id
      classrooms = Classrooms::Classroom.where(teacher_id: teacher_id)

      if classrooms.any?
        context.classrooms = classrooms.map do |classroom|
          student_count = Classrooms::ClassroomStudent.where(classroom_id: classroom.id).count
          {
            id: classroom.id,
            title: classroom.title,
            subject: classroom.subject,
            class_time: classroom.class_time,
            days_of_week: classroom.days_of_week,
            teacher_id: classroom.teacher_id,
            student_count: student_count
          }
        end
      else
        context.fail!(message: NO_CLASSROOMS_FOUND, status: :not_found)
      end
    rescue => e
      context.fail!(message: e.message)
    end
  end
end
