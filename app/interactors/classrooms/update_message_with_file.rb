module Classrooms
    class UpdateMessageWithFile
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

        unless url_result.success?
          context.message.destroy
          context.fail!(
            message: URL_GENERATION_FAIL,
            status: :unprocessable_entity
          )
        end

        upload_result = ::Classwork::FileUploads.call(
          file: context.file,
          file_url: url_result.presigned_urls.first[:signedUrl],
          action: :upload_to_s3
        )

        unless upload_result.success?
          context.message.destroy
          context.fail!(
            message: ATTACHMENT_UPLOAD_FAIL,
            status: :unprocessable_entity
          )
        end

        context.message.update!(download_url: upload_result.file_url)
      rescue => e
        context.message.destroy
        context.fail!(
          message: e.message,
          status: :internal_server_error
        )
      end
    end
end
