module Classwork
  class FileUploads
    include Interactor

    def call
      case context.action
      when :generate_presigned_url
        generate_presigned_urls
      when :upload_to_s3
        upload_to_s3
      when :delete_file
        delete_file
      end
    rescue StandardError => e
      context.fail!(message: e.message)
    end

    private

    def generate_presigned_urls
      context.presigned_urls = context.files.map do |file|
        {
          name: file[:name],
          type: file[:type],
          signedUrl: generate_url(file, context.folder || "assignments")
        }
      end
    end

    def generate_url(file, folder)
      key = "#{folder}/#{SecureRandom.uuid}/#{file[:name]}"
      object = S3_BUCKET.object(key)

      object.presigned_url(
        :put,
        expires_in: 3600,
        content_type: file[:type]
      )
    end

    def upload_to_s3
      return context.fail!(message: "Missing file or URL") unless context.file && context.file_url

      begin
        clean_url = clean_presigned_url(context.file_url)
        uri = URI.parse(clean_url)
        request = Net::HTTP::Put.new(uri)
        request.body = context.file.read
        request["Content-Type"] = context.file.content_type

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = false if uri.host == "localhost"

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          context.file_url = clean_url.split("?").first
        else
          context.fail!(message: "Upload failed - Status: #{response.code}, Body: #{response.body}")
        end

      rescue URI::InvalidURIError => e
        context.fail!(message: "Invalid URL format: #{e.message}")
      rescue StandardError => e
        context.fail!(message: "Upload failed: #{e.message}")
      end
    end

    def clean_presigned_url(url)
      url.gsub('\\u0026', "&")
         .gsub('\\\\&', "&")
         .gsub('\\&', "&")
         .gsub("%3A", ":")
         .gsub("%2F", "/")
    end

    def delete_file
      return context.fail!(message: "Missing file URL") unless context.file_url

      begin
        uri = URI(context.file_url)
        decoded_path = CGI.unescape(uri.path)
        key = decoded_path.sub(/^\/[^\/]+\//, "")

        object = S3_BUCKET.object(key)

        unless object.exists?
          return context.fail!(message: "File does not exist for key: #{key}")
        end

        object.delete
        context.success = true
      rescue Aws::S3::Errors::ServiceError => e
        context.fail!(message: "Failed to delete file: #{e.message}")
      end
    end
  end
end
