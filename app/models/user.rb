class User < ApplicationRecord
    validates :first_name, :last_name, :gender, :email, :password, :user_type, presence: true
    validates :first_name, :last_name, length: { maximum: 50, message: "must be at most 50 characters long" }
    validates :user_type, inclusion: { in: %w(student teacher), message: "%{value} is not a valid user type" }
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
    validates :password, length: { minimum: 8, message: "must be at least 8 characters long" }
    validates :gender, inclusion: { in: ['male', 'female', 'prefer not to say'], message: "%{value} is not a valid gender" }
  end