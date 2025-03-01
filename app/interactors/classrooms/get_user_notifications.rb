module Classrooms
    class GetUserNotifications
      include Interactor
      include Constants::ClassroomConstants

      def call
        notifications = fetch_notifications
        context.notifications = notifications_to_array(notifications)
      rescue StandardError => e
        context.fail!(
          message: NOTIFICATION_RETRIEVAL_FAIL,
          error: e.message
        )
      end

      private

      def fetch_notifications
        Classwork::Notification
          .includes(assignment: :classroom)
          .where(receiver_id: context.user_id)
          .order(created_at: :desc)
      end

      def notifications_to_array(notifications)
        notifications.map do |notification|
          assignment = notification.assignment
          classroom = assignment&.classroom

          {
            id: notification.id,
            notification_type: notification.notification_type,
            title: notification.title,
            message: notification.message,
            is_read: notification.is_read,
            assignment_id: notification.assignment_id,
            classroom_title: classroom&.title,
            classroom_id: classroom&.id,
            created_at: notification.created_at,
            broadcast_at: notification.broadcast_at
          }
        end
      end
    end
end
