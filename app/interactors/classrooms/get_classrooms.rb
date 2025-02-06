module Classrooms
  class GetClassrooms
    include Interactor

    def call
      teacher_id = context.teacher_id
      classrooms = Classrooms::Classroom.where(teacher_id: teacher_id)

        if classrooms.any?
          context.classrooms = classrooms.map do |classroom|
            {
              id: classroom.id,
              title: classroom.title,
              subject: classroom.subject,
              class_time: classroom.class_time,
              days_of_week: classroom.days_of_week,
              teacher_id: classroom.teacher_id
            }
          end
        else
          context.fail!(message: "No classrooms found", status: :not_found)
        end
      rescue => e
        context.fail!(message: e.message)
      end
    end
end
