module Classrooms
    class UpdateNotificationsRead
      include Interactor
      include Constants::ClassroomConstants

      def call
        notification_ids = context.notification_ids

        if notification_ids.blank?
          context.fail!(
            message: NO_NOTIFICATION_IDS_PROVIDED,
            error: MISSING_NOTIFICATION_IDS
          )
        end

        updated_count = Classwork::Notification
          .where(id: notification_ids)
          .update_all(is_read: true)

        context.updated_count = updated_count
      rescue StandardError => e
        context.fail!(
          message: NOTIFICATION_UPDATE_FAIL,
          error: e.message
        )
      end
    end
end
