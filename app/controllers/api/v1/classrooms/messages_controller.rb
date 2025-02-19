module Api
    module V1
      module Classrooms
        class MessagesController < ApplicationController
          include ResponseHelper
          include Constants::MessageConstants
          include FileUploadable
          before_action :doorkeeper_authorize!

          def index
            result = ::Classrooms::GetMessages.call(
              classroom_id: params[:classroom_id]
            )

            if result.success?
              success_response(
                data: result.messages,
                message: MESSAGES_RETRIEVED_SUCCESS
              )
            else
              error_response(
                message: result.message,
                status: result.status,
                error: MESSAGES_RETRIEVAL_FAIL
              )
            end
          end

          def create
            file_url = nil

            if params[:file].present?
              file_result = ::Classrooms::UploadMessageFile.call(
                file: params[:file]
              )

              return error_response(
                message: file_result.message,
                status: file_result.status,
                error: MESSAGE_CREATION_FAIL
              ) unless file_result.success?

              file_url = file_result.file_url
            end

            message_result = ::Classrooms::CreateMessage.call(
              content: params[:content],
              user_id: params[:user_id],
              classroom_id: params[:classroom_id],
              download_url: file_url
            )

            if message_result.success?
              success_response(
                data: message_result.message.as_json(include: {
                  user: {
                    only: [ :id ],
                    methods: [ :first_name, :last_name, :user_type ]
                  }
                }),
                message: MESSAGE_CREATION_SUCCESS,
                status: :created
              )
            else
              error_response(
                message: message_result.message,
                status: :unprocessable_entity,
                error: MESSAGE_CREATION_FAIL
              )
            end
          rescue => e
            error_response(
              message: e.message,
              status: :internal_server_error,
              error: MESSAGE_CREATION_FAIL
            )
          end
        end
      end
    end
end
