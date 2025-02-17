module Classrooms
  class Message < ApplicationRecord
    belongs_to :user, class_name: "Users::User"
    belongs_to :classroom, class_name: "Classrooms::Classroom"

    validates :content, presence: true
  end
end
