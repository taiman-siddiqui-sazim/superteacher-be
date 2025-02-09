module Classwork
  class Assignment < ApplicationRecord
    belongs_to :classroom, class_name: "Classrooms::Classroom"

    validates :title, presence: true, length: { maximum: 255 }
    validates :instruction, presence: true
    validates :due_date, presence: true
    validates :classroom_id, presence: true
  end
end
