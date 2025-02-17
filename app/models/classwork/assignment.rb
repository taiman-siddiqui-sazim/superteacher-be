module Classwork
  class Assignment < ApplicationRecord
    belongs_to :classroom, class_name: "Classrooms::Classroom"
    has_many :submissions, class_name: "Classwork::Submission", foreign_key: :assignment_id, dependent: :destroy

    VALID_TYPES = [ "assignment", "exam" ].freeze
    DATETIME_FORMAT = /\A\d{2}\/\d{2}\/\d{4}\s\d{2}:\d{2}\z/

    validates :title, presence: true, length: { maximum: 255 }
    validates :instruction, presence: true, length: { maximum: 5000 }
    validates :due_date, presence: true
    validates :classroom_id, presence: true
    validates :assignment_type, presence: true, inclusion: { in: VALID_TYPES }
    validate :validate_due_date_format
    validate :validate_due_date_future

    private

    def validate_due_date_format
      return if due_date.blank?

      unless due_date =~ DATETIME_FORMAT
        errors.add(:due_date, "must be in format dd/mm/yyyy hh:mm")
      end
    end

    def validate_due_date_future
      return if due_date.blank?
      return unless due_date =~ DATETIME_FORMAT

      parsed_date = DateTime.strptime(due_date, "%d/%m/%Y %H:%M")
      if parsed_date <= DateTime.now
        errors.add(:due_date, "must be in the future")
      end
    end
  end
end
