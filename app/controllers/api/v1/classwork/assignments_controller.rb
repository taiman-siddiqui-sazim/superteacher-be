module Api
  module V1
    module Classwork
      class AssignmentsController < ApplicationController
        include ResponseHelper
        include Constants::ClassworkConstants
        before_action :doorkeeper_authorize!

        def create_assignment
          result = ::Classwork::CreateAssignment.call(
            params: assignment_params,
            classroom_id: params[:classroom_id]
          )

          unless result.success?
            return error_response(
              message: result.message,
              status: result.status,
              error: ASSIGNMENT_CREATION_FAIL
            )
          end

          file_uploads_controller = initialize_file_uploads_controller({
            file: params[:file],
            file_url: params[:file_url]
          })
          upload_result = file_uploads_controller.upload_file

          unless upload_result[:success?]
            result.assignment.destroy!
            return error_response(
              message: upload_result[:message],
              status: :unprocessable_entity,
              error: upload_result[:error]
            )
          end

          result.assignment.update!(file_url: upload_result[:data][:file_url])
          success_response(data: result.assignment, message: ASSIGNMENT_CREATION_SUCCESS)
        end

        def get_assignments_by_classroom
          result = ::Classwork::GetAssignments.call(
            classroom_id: params[:classroom_id]
          )

          if result.success?
            success_response(
              data: result.assignments,
              message: ASSIGNMENTS_RETRIEVE_SUCCESS
            )
          else
            error_response(
              message: result.message,
              status: result.status,
              error: ERROR_NO_ASSIGNMENTS
            )
          end
        end

        def delete_assignment
          assignment = ::Classwork::Assignment.find_by(id: params[:id])
          return error_response(
            message: ASSIGNMENT_NOT_FOUND,
            status: :not_found,
            error: ASSIGNMENT_DELETE_FAIL
          ) unless assignment

          file_uploads_controller = initialize_file_uploads_controller({
            file_url: assignment.file_url
          })
          delete_result = file_uploads_controller.delete_file

          unless delete_result[:success?]
            return error_response(
              message: delete_result[:message],
              status: :unprocessable_entity,
              error: ASSIGNMENT_DELETE_FAIL
            )
          end

          assignment.destroy!
          success_response(
            data: {},
            message: ASSIGNMENT_DELETE_SUCCESS
          )
        end

        def update_assignment_fields
          assignment = ::Classwork::Assignment.find_by(id: params[:id])
          return error_response(
            message: ASSIGNMENT_NOT_FOUND,
            status: :not_found,
            error: ASSIGNMENT_UPDATE_FAIL
          ) unless assignment

          if assignment.update(update_assignment_params)
            success_response(
              data: assignment,
              message: ASSIGNMENT_UPDATE_SUCCESS
            )
          else
            error_response(
              message: assignment.errors.full_messages.join(", "),
              status: :unprocessable_entity,
              error: ASSIGNMENT_UPDATE_FAIL
            )
          end
        end

        def update_file
          assignment = ::Classwork::Assignment.find_by(id: params[:id])
          return error_response(
            message: ASSIGNMENT_NOT_FOUND,
            status: :not_found,
            error: ASSIGNMENT_CREATION_FAIL
          ) unless assignment

          old_file_url = assignment.file_url

          file_uploads_controller = initialize_file_uploads_controller({
            file: params[:file],
            file_url: params[:file_url]
          })
          upload_result = file_uploads_controller.upload_file

          unless upload_result[:success?]
            return error_response(
              message: upload_result[:message],
              status: :unprocessable_entity,
              error: FILE_UPDATE_FAIL
            )
          end

          assignment.update!(file_url: upload_result[:data][:file_url])

          file_uploads_controller = initialize_file_uploads_controller({
            file_url: old_file_url
          })
          delete_result = file_uploads_controller.delete_file

          if delete_result[:success?]
            message = FILE_UPDATE_SUCCESS
          else
            Rails.logger.warn("Warning: Failed to delete old file at #{old_file_url}")
            message = FILE_UPDATE_SUCCESS
          end

          success_response(data: assignment, message: message)
        end

        private

        def initialize_file_uploads_controller(controller_params)
          controller = FileUploadsController.new
          controller.request = request
          controller.response = response
          controller.params = controller_params
          controller
        end

        def assignment_params
          params.require(:assignment).permit(:title, :instruction, :due_date, :assignment_type)
        end

        def update_assignment_params
          params.require(:assignment).permit(:title, :instruction, :due_date)
        end
      end
    end
  end
end
