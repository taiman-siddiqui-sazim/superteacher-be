module Api
    module V1
      module Classwork
        class SubmissionsController < ApplicationController
          include ResponseHelper
          include Constants::ClassworkConstants
          include FileUploadable
          before_action :doorkeeper_authorize!

          def create_submission
            file_uploads_controller = initialize_file_uploads_controller({
              file: params[:file],
              file_url: params[:file_url]
            })
            upload_result = file_uploads_controller.upload_file

            unless upload_result[:success?]
              return error_response(
                message: upload_result[:message],
                status: :unprocessable_entity,
                error: SUBMISSION_UPLOAD_FAIL
              )
            end

            result = ::Classwork::CreateSubmission.call(
              user_id: doorkeeper_token.resource_owner_id,
              assignment_id: params[:assignment_id],
              file_url: upload_result[:data][:file_url]
            )

            if result.success?
              success_response(
                data: result.submission,
                message: SUBMISSION_CREATION_SUCCESS
              )
            else
              error_response(
                message: result.message,
                status: result.status,
                error: SUBMISSION_CREATION_FAIL
              )
            end
          end

          def update_submission
            submission = ::Classwork::Submission.find_by(id: params[:id])
            return error_response(
              message: SUBMISSION_NOT_FOUND,
              status: :not_found,
              error: SUBMISSION_UPDATE_FAIL
            ) unless submission

            old_file_url = submission.file_url

            file_uploads_controller = initialize_file_uploads_controller({
              file: params[:file],
              file_url: params[:file_url]
            })
            upload_result = file_uploads_controller.upload_file

            unless upload_result[:success?]
              return error_response(
                message: upload_result[:message],
                status: :unprocessable_entity,
                error: SUBMISSION_UPDATE_FAIL
              )
            end

            result = ::Classwork::UpdateSubmission.call(
              submission: submission,
              file_url: upload_result[:data][:file_url]
            )

            unless result.success?
              return error_response(
                message: result.message,
                status: result.status,
                error: SUBMISSION_UPDATE_FAIL
              )
            end

            file_uploads_controller = initialize_file_uploads_controller({
              file_url: old_file_url
            })
            delete_result = file_uploads_controller.delete_file

            message = delete_result[:success?] ?
              SUBMISSION_UPDATE_SUCCESS :
              "#{SUBMISSION_UPDATE_SUCCESS} (Warning: Failed to delete old file at #{old_file_url})"

            success_response(data: submission, message: message)
          end

          def get_assignment_submissions
            result = ::Classwork::GetSubmissions.call(
              assignment_id: params[:assignment_id]
            )

            if result.success?
              success_response(
                data: result.submissions,
                message: SUBMISSIONS_RETRIEVE_SUCCESS
              )
            else
              error_response(
                message: result.message,
                status: result.status,
                error: SUBMISSIONS_RETRIEVE_FAIL
              )
            end
          end

          def get_submitted_assignment_by_user
            result = ::Classwork::GetSubmittedAssignment.call(
                assignment_id: params[:assignment_id],
                user_id: params[:user_id]
            )

            if result.success?
              success_response(
                data: result.submission,
                message: SUBMISSIONS_RETRIEVE_SUCCESS
              )
            else
              error_response(
                message: result.message,
                status: result.status,
                error: SUBMISSIONS_RETRIEVE_FAIL
              )
            end
          end

          private

          def submission_params
            params.permit(:file, :file_url)
          end
        end
      end
    end
end
