module Classrooms
    class ExamReminderJob
      include Sidekiq::Job
      include Constants::ClassworkConstants

      def perform
        Rails.logger.info "Starting ExamReminderJob at #{Time.current + 6.hours}"

        start_time = Time.current.utc + 6.hours
        end_time = start_time + 24.hours

        Rails.logger.info "Checking for exams between #{start_time} and #{end_time}"

        upcoming_exams = ::Classwork::Assignment.includes(:classroom)
          .where(assignment_type: "exam")
          .find_each do |exam|
            Rails.logger.info "Checking exam: #{exam.title}"
            begin
              due_date = DateTime.strptime(exam.due_date, "%d/%m/%Y %H:%M").utc
              Rails.logger.info "Due date (UTC): #{due_date}"

              if due_date.between?(start_time, end_time)
                Rails.logger.info "Exam falls within notification window"
                create_exam_reminders(exam)
              else
                Rails.logger.info "Exam outside notification window: #{due_date} not between #{start_time} and #{end_time}"
              end
            rescue StandardError => e
              Rails.logger.error "Failed to parse due date for exam #{exam.id}: #{e.message}"
            end
          end
      end

      private

      def create_exam_reminders(exam)
        Rails.logger.info "Creating reminders for exam: #{exam.title}"
        notifications = []

        exam.classroom_users.each do |receiver|
          Rails.logger.info "Creating reminder for user: #{receiver.email}"
          next if ::Classwork::Notification.already_notified?(
            assignment: exam,
            receiver: receiver,
            notification_type: EXAM_REMINDER
          )

          notifications << ::Classwork::Notification.create!(
            assignment: exam,
            receiver: receiver,
            notification_type: EXAM_REMINDER,
            title: "Upcoming #{exam.assignment_type.capitalize}",
            message: "#{exam.assignment_type.capitalize} '#{exam.title}' is available within 24 hours!"
          )
        end

        # Broadcast to classroom if new notifications were created
        if notifications.any?
          broadcast_exam_reminder(exam, notifications)
        end
      rescue StandardError => e
        Rails.logger.error "Failed to create reminders for exam #{exam.id}: #{e.message}"
      end

      def broadcast_exam_reminder(exam, notifications)
        Rails.logger.info "Broadcasting reminder for exam: #{exam.title}"

        classroom_title = exam.classroom&.title
        Rails.logger.info "Classroom title: #{classroom_title}"

        ActionCable.server.broadcast(
          "classroom_notifications_channel_#{exam.classroom_id}",
          {
            type: EXAM_REMINDER,
            exam_id: exam.id,
            notification_ids: notifications.map(&:id),
            classroom_id: exam.classroom_id,
            classroom_title: classroom_title,
            title: "Upcoming #{exam.assignment_type.capitalize}",
            message: "#{exam.assignment_type.capitalize} '#{exam.title}' is available within 24 hours!",
            created_at: Time.current.in_time_zone(DEFAULT_TIMEZONE)
          }
        )

        # Mark all notifications as broadcast
        notifications.each { |n| n.update!(broadcast_at: Time.current.in_time_zone(DEFAULT_TIMEZONE)) }
        Rails.logger.info "Marked #{notifications.count} notifications as broadcast"
      end
    end
end
