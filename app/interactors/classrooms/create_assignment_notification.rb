module Classrooms
    class CreateAssignmentNotification
      include Interactor
      include Constants::ClassroomConstants
      include Constants::ClassworkConstants

      def call
        assignment = context.assignment
        Rails.logger.info "Creating notifications for assignment: #{assignment.title}"

        classroom_users = assignment.classroom.users
        teacher_id = assignment.classroom.teacher_id
        student_users = classroom_users.reject { |user| user.id == teacher_id }

        notifications = []

        student_users.each do |user|
           next if Classwork::Notification.exists?(
            assignment_id: assignment.id,
            receiver_id: user.id,
            notification_type: CLASSWORK_CREATION
          )

          notifications << Classwork::Notification.create!(
            assignment_id: assignment.id,
            receiver_id: user.id,
            notification_type: CLASSWORK_CREATION,
            title: "Classwork Created",
            message: "#{assignment.title} #{assignment.assignment_type} has been uploaded",
            is_read: false
          )
        end

        if notifications.any?
          broadcast_classwork_creation(assignment, notifications)
        end

        context.notifications = notifications
      rescue StandardError => e
        Rails.logger.error "Failed to create assignment notifications: #{e.message}"
        context.fail!(message: ASSIGNMENT_NOTIFICATION_FAIL, error: e.message)
      end

      private

      def broadcast_classwork_creation(assignment, notifications)
        Rails.logger.info "Broadcasting classwork creation notification for assignment: #{assignment.title}"

        classroom_title = assignment.classroom&.title

        ActionCable.server.broadcast(
          "classroom_notifications_channel_#{assignment.classroom_id}",
          {
            type: CLASSWORK_CREATION,
            assignment_id: assignment.id,
            notification_ids: notifications.map(&:id),
            classroom_id: assignment.classroom_id,
            classroom_title: classroom_title,
            title: "Classwork Created",
            message: "#{assignment.title} #{assignment.assignment_type} has been uploaded",
            created_at: Time.current.in_time_zone(DEFAULT_TIMEZONE)
          }
        )

        notifications.each { |n| n.update!(broadcast_at: Time.current.in_time_zone(DEFAULT_TIMEZONE)) }
        Rails.logger.info "Marked #{notifications.count} notifications as broadcast"
      end
    end
end
