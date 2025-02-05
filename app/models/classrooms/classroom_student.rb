module Classrooms
  class ClassroomStudent < ApplicationRecord
    belongs_to :classroom, class_name: "Classrooms::Classroom"
    belongs_to :student, class_name: "Users::Student"

    validates :enroll_date, presence: true
  end
end
