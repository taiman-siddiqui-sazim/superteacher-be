module Api
    module V1
      module Classrooms
        class NotificationsController < ApplicationController
          include ResponseHelper
          include Constants::ClassroomConstants
          before_action :doorkeeper_authorize!

          def get_user_notifications
            result = ::Classrooms::GetUserNotifications.call(
              user_id: params[:user_id]
            )

            if result.success?
              success_response(
                data: result.notifications,
                message: NOTIFICATION_RETRIEVAL_SUCCESS
              )
            else
              error_response(
                message: result.message,
                error: result.error,
                status: :internal_server_error
              )
            end
          end

          def get_unread_notifications_for_user
            result = ::Classrooms::GetUnreadNotificationsForUser.call(
              user_id: params[:user_id]
            )

            if result.success?
              success_response(
                data: result.notifications,
                message: NOTIFICATION_RETRIEVAL_SUCCESS
              )
            else
              error_response(
                message: result.message,
                error: result.error,
                status: :internal_server_error
              )
            end
          end

          def update_notifications_read
            result = ::Classrooms::UpdateNotificationsRead.call(
              notification_ids: params[:notification_ids]
            )

            if result.success?
              success_response(
                data: { updated_count: result.updated_count },
                message: NOTIFICATION_UPDATE_SUCCESS
              )
            else
              error_status = result.message == NO_NOTIFICATION_IDS_PROVIDED ? :bad_request : :internal_server_error

              error_response(
                message: result.message,
                error: result.error,
                status: error_status
              )
            end
          end

          private

          def notification_params
            params.permit(:user_id, classroom_ids: [], notification_ids: [])
          end
        end
      end
    end
end
