module Classrooms
  class Classroom < ApplicationRecord
    belongs_to :user, class_name: "Users::User", foreign_key: :teacher_id
    has_many :classroom_students, class_name: "Classrooms::ClassroomStudent", dependent: :destroy
    has_many :students, through: :classroom_students, class_name: "Users::Student", source: :student
    has_many :assignments, class_name: "Classwork::Assignment", dependent: :destroy
    has_one :meet_link, class_name: "Classrooms::MeetLink", dependent: :destroy
    has_many :messages, class_name: "Classrooms::Message", dependent: :destroy

    validates :title, presence: true, length: { in: 1..100 }
    validates :subject, presence: true
    validates :class_time, presence: true, length: { in: 5..15 }
    validates :days_of_week, presence: true, length: { in: 1..4 }
    validates :teacher_id, uniqueness: { scope: [ :title, :subject, :class_time, :days_of_week ], message: "duplicate record exists" }
    validate :valid_days_of_week
    validate :subject_exists
    validate :valid_teacher

    private

    def valid_days_of_week
      valid_days = %w[sunday monday tuesday wednesday thursday friday saturday]
      if days_of_week.any? { |day| !valid_days.include?(day.downcase) }
        errors.add(:days_of_week, "must contain valid days of the week")
      end
    end

    def subject_exists
      unless Classrooms::Subject.exists?(subject: subject)
        errors.add(:subject, "must be a valid subject")
      end
    end

    def valid_teacher
      user = Users::User.find_by(id: teacher_id)
      if user.nil? || user.user_type != "teacher"
        errors.add(:teacher_id, "must be a valid teacher")
      end
    end
  end
end
