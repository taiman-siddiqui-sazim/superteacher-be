class User < ApplicationRecord
<<<<<<< HEAD
  has_one :student, foreign_key: :user_id, dependent: :destroy

  has_secure_password

  validates :first_name, :last_name, :gender, :email, :user_type, presence: true
  validates :first_name, :last_name, length: { maximum: 50, message: "must be at most 50 characters long" }
  validates :user_type, inclusion: { in: %w[student teacher], message: "%{value} is not a valid user type" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, uniqueness: true
  validates :password, length: { in: 8..128, message: "must be between 8 and 128 characters long" }, allow_nil: true
  validates :password, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,128}\z/,
                                 message: "must include at least one lowercase letter, one uppercase letter, one digit,
                                 and one special character" }, allow_nil: true
  validates :gender, inclusion: { in: [ "male", "female", "prefer not to say" ], message: "%{value} is not a valid gender" }
end
=======
    has_one :student, foreign_key: :id, dependent: :destroy
  
    validates :first_name, :last_name, :gender, :email, :password, :user_type, presence: true
    validates :first_name, :last_name, length: { maximum: 50, message: "must be at most 50 characters long" }
    validates :user_type, inclusion: { in: %w(student teacher), message: "%{value} is not a valid user type" }
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
    validates :password, length: { minimum: 8, message: "must be at least 8 characters long" }
    validates :gender, inclusion: { in: ['male', 'female', 'prefer not to say'], message: "%{value} is not a valid gender" }
  
    validate :student_record_exists_if_user_type_is_student
  
    private
  
    def student_record_exists_if_user_type_is_student
        if user_type == 'student' && !Student.exists?(id: id)
          errors.add(:base, "Student record must exist with the same id if user type is student")
        end
    end
  end
>>>>>>> 87ac406 (feat(st-3): create user and student models with validations and tests)
