class UniqueCode < ApplicationRecord
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
    validates :unique_code, presence: true, format: { with: /\A\d{6}\z/ }, uniqueness: true
    validates :attempts_left, presence: true, inclusion: { in: 0..3 }
end
