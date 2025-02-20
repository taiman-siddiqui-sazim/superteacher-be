module Classrooms
    class UploadMessageFile
      include Interactor
      include Constants::MessageConstants

      def call
        url_result = ::Classwork::FileUploads.call(
          files: [ {
            name: context.file.original_filename,
            type: context.file.content_type
          } ],
          folder: "messages",
          action: :generate_presigned_url
        )

        context.fail!(
          message: URL_GENERATION_FAIL,
          status: :unprocessable_entity
        ) unless url_result.success?

        upload_result = ::Classwork::FileUploads.call(
          file: context.file,
          file_url: url_result.presigned_urls.first[:signedUrl],
          action: :upload_to_s3
        )

        context.fail!(
          message: ATTACHMENT_UPLOAD_FAIL,
          status: :unprocessable_entity
        ) unless upload_result.success?

        context.file_url = upload_result.file_url
      rescue => e
        context.fail!(
          message: e.message,
          status: :internal_server_error
        )
      end
    end
end
