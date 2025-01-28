module Users
  class Teacher < ApplicationRecord
    belongs_to :user

    validates :major_subject, presence: true, length: { maximum: 50 }
    validates :subjects, presence: true, length: { minimum: 1 }
    validates :highest_education, presence: true, inclusion: { in: %w[bachelors masters phd], message: "%{value} is not a valid highest education" }

    validate :user_record_must_be_teacher

    private

    def user_record_must_be_teacher
      if user.nil? || user.user_type != "teacher"
        errors.add(:user, "must exist and have a user_type of 'teacher'")
      end
    end
  end
end
