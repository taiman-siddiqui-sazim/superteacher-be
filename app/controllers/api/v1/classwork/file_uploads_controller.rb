module Api
  module V1
    module Classwork
      class FileUploadsController < ApplicationController
        include ResponseHelper
        include Constants::ClassworkConstants
        before_action :doorkeeper_authorize!

        def create_url
          result = ::Classwork::FileUploads.call(
            files: file_params[:files],
            action: :generate_presigned_url
          )

          if result.success?
            success_response(
              data: result.presigned_urls,
              message: PRESIGNED_URL_GENERATION_SUCCESS
            )
          else
            error_response(
              message: result.message,
              status: :unprocessable_entity,
              error: URL_GENERATION_FAIL
            )
          end
        end

        def upload_file
          result = ::Classwork::FileUploads.call(
            file: params[:file],
            file_url: params[:file_url],
            action: :upload_to_s3
          )

          if result.success?
            OpenStruct.new(
              success?: true,
              data: { file_url: result.file_url },
              message: FILE_UPLOAD_SUCCESS
            )
          else
            OpenStruct.new(
              success?: false,
              message: result.message,
              error: FILE_UPLOAD_FAIL
            )
          end
        end

        def delete_file
          result = ::Classwork::FileUploads.call(
            file_url: params[:file_url],
            action: :delete_file
          )

          if result.success?
            OpenStruct.new(
              success?: true,
              message: FILE_DELETE_SUCCESS
            )
          else
            OpenStruct.new(
              success?: false,
              message: result.message,
              error: FILE_DELETE_FAIL
            )
          end
        end

        private

        def file_params
          params.permit(files: [ :name, :type ])
        end
      end
    end
  end
end
