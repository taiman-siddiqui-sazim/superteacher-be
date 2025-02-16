module Classrooms
    class MeetLink < ApplicationRecord
      belongs_to :classroom, class_name: "Classrooms::Classroom"
      validates :meet_link, presence: true,
                           uniqueness: true,
                           format: {
                             with: /\Ahttps:\/\/meet\.google\.com\/[a-zA-Z0-9-]+\z/,
                             message: "must be a valid Google Meet link"
                           }
    end
end
