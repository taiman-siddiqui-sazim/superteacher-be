class User < ApplicationRecord
  has_one :student, foreign_key: :user_id, dependent: :destroy

  validates :first_name, :last_name, :gender, :email, :password, :user_type, presence: true
  validates :first_name, :last_name, length: { maximum: 50, message: "must be at most 50 characters long" }
  validates :user_type, inclusion: { in: %w[student teacher], message: "%{value} is not a valid user type" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :password, length: { minimum: 8, message: "must be at least 8 characters long" }
  validates :password, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}\z/,
                                 message: "must include at least one lowercase letter, one uppercase letter, one digit,
                                 and one special character" }
  validates :gender, inclusion: { in: [ "male", "female", "prefer not to say" ], message: "%{value} is not a valid gender" }

  validate :student_record_exists_if_user_type_is_student

  private

  def student_record_exists_if_user_type_is_student
    if user_type == "student" && !Student.exists?(user_id: id)
      errors.add(:base, "Student record must exist with the same user_id if user type is student")
    end
  end
end
