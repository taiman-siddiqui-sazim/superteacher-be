module Classwork
    class Notification < ApplicationRecord
      belongs_to :assignment, class_name: "Classwork::Assignment"
      belongs_to :receiver, class_name: "Users::User"

      validates :notification_type, presence: true
      validates :title, presence: true
      validates :message, presence: true

      scope :unread, -> { where(is_read: false) }
      scope :exam_reminders, -> { where(notification_type: "exam_reminder") }

      class << self
        def notify_users(assignment:, receivers:, notification_type:)
          receivers.each do |receiver|
            next if already_notified?(
              assignment: assignment,
              receiver: receiver,
              notification_type: notification_type
            )

            create!(
              assignment: assignment,
              receiver: receiver,
              notification_type: notification_type,
              title: generate_title(assignment, notification_type),
              message: generate_message(assignment, notification_type)
            )
          end
        end

        def already_notified?(assignment:, receiver:, notification_type:)
          exists?(
            assignment_id: assignment.id,
            receiver_id: receiver.id,
            notification_type: notification_type,
            created_at: 24.hours.ago..Time.current
          )
        end

        private

        def generate_title(assignment, type)
          case type
          when "exam_reminder"
            "Upcoming #{assignment.assignment_type.capitalize}"
          else
            "Notification"
          end
        end

        def generate_message(assignment, type)
          case type
          when "exam_reminder"
            "#{assignment.assignment_type.capitalize} '#{assignment.title}' is available within 24 hours!"
          else
            "You have a new notification"
          end
        end
      end

      def mark_as_read!
        update!(is_read: true)
      end
    end
end
