module Classwork
    class Material < ApplicationRecord
      belongs_to :classroom, class_name: "Classrooms::Classroom"

      validates :title, presence: true, length: { maximum: 255 }
      validates :instruction, presence: true, length: { maximum: 5000 }
      validates :classroom_id, presence: true

      def classroom_users
        classroom.users
      end
    end
end
