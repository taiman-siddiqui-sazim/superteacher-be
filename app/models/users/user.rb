module Users
  class User < ApplicationRecord
    has_one :student, class_name: "Users::Student", foreign_key: :user_id, dependent: :destroy
    has_one :teacher, class_name: "Users::Teacher", foreign_key: :user_id, dependent: :destroy
    has_many :classrooms, class_name: "Classrooms::Classroom", foreign_key: :teacher_id, dependent: :destroy
    has_many :submissions, class_name: "Classwork::Submission", foreign_key: :user_id, dependent: :destroy
    has_many :messages, class_name: "Classrooms::Message", dependent: :destroy

    has_secure_password

    validates :first_name, :last_name, :gender, :email, :user_type, presence: true
    validates :first_name, :last_name, length: { maximum: 50, message: "must be at most 50 characters long" }
    validates :user_type, inclusion: { in: %w[student teacher], message: "%{value} is not a valid user type" }
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, uniqueness: true
    validates :password, length: { in: 8..128, message: "must be between 8 and 128 characters long" }, allow_nil: true
    validates :password, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,128}\z/,
                                   message: "must include at least one lowercase letter, one uppercase letter, one digit,
                                   and one special character" }, allow_nil: true
    validates :gender, inclusion: { in: [ "male", "female", "other" ], message: "%{value} is not a valid gender" }
    validates :otp, format: { with: /\A\d{6}\z/, message: "must be a string containing 6 digits" }, allow_nil: true

    def otp_expired?
      otp_sent_at < 5.minutes.ago
    end
  end
end
