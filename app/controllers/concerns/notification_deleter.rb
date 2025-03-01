module NotificationDeleter
    extend ActiveSupport::Concern

    def delete_outdated_notifications(assignment_id)
      begin
        require "net/http"
        require "uri"

        protocol = request.protocol
        host_with_port = request.host_with_port
        base_url = "#{protocol}#{host_with_port}"

        uri = URI.parse("#{base_url}/api/v1/classrooms/notifications/#{assignment_id}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")

        req = Net::HTTP::Delete.new(uri.path)
        req["Authorization"] = request.headers["Authorization"]
        req["Content-Type"] = "application/json"

        response = http.request(req)

        if response.code.to_i.between?(200, 299)
          response_body = JSON.parse(response.body)
          deleted_count = response_body.dig("data", "deleted_count") || 0
          Rails.logger.info("Successfully deleted #{deleted_count} outdated notifications for assignment #{assignment_id}")
        else
          Rails.logger.warn("Failed to delete notifications for assignment #{assignment_id}: #{response.body}")
        end
      rescue StandardError => e
        Rails.logger.error("Error when deleting notifications for assignment #{assignment_id}: #{e.message}")
      end
    end
end
