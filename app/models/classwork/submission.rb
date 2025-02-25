module Classwork
    class Submission < ApplicationRecord
      belongs_to :assignment, class_name: "Classwork::Assignment"
      belongs_to :user, class_name: "Users::User"

      validates :submitted_at, presence: true
      validates :file_url, presence: true
      validates :assignment_id, presence: true
      validates :user_id, presence: true
      validates :is_late, inclusion: { in: [ true, false ] }

      scope :for_assignment, ->(assignment_id) { where(assignment_id: assignment_id) }

      def self.parse_date_string(date_string)
        DateTime.strptime(date_string, "%d/%m/%Y %H:%M")
      end

      def self.check_if_late?(submitted_at, due_date_string)
        due_date = parse_date_string(due_date_string)
        submitted_at = DateTime.parse(submitted_at.to_s).strftime("%d/%m/%Y %H:%M")
        submitted_at = parse_date_string(submitted_at)

        submitted_at > due_date
      rescue ArgumentError
        false
      end
    end
end
