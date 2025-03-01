module Classrooms
    class DeleteUpdatedNotifications
      include Interactor
      include Constants::ClassworkConstants
      include Constants::ClassroomConstants

      def call
        assignment_id = context.assignment_id

        unless assignment_id.present?
          context.fail!(
            message: MISSIING_ASSIGNMENT_ID,
            error: "Assignment ID is required"
          )
        end

        notifications = Classwork::Notification.where(
          assignment_id: assignment_id,
          notification_type: "exam_reminder"
        )

        context.deleted_count = notifications.count
        notifications.destroy_all

        Rails.logger.info "Successfully deleted #{context.deleted_count} outdated notifications for assignment #{assignment_id}"
      rescue StandardError => e
        Rails.logger.error "Failed to delete notifications for assignment #{assignment_id}: #{e.message}"
        context.fail!(
          message: NOTIFICATION_DELETE_FAIL,
          error: e.message
        )
      end
    end
end
