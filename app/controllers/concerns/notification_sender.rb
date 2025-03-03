module NotificationSender
    extend ActiveSupport::Concern

    def create_notifications_for_assignment(assignment_id)
      begin
        require "net/http"
        require "uri"

        protocol = request.protocol # "http://" or "https://"
        host_with_port = request.host_with_port # "example.com:3000" or "localhost:3000"
        base_url = "#{protocol}#{host_with_port}"

        uri = URI.parse("#{base_url}/api/v1/classrooms/notifications/assignments/#{assignment_id}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")

        req = Net::HTTP::Post.new(uri.path)
        req["Authorization"] = request.headers["Authorization"]
        req["Content-Type"] = "application/json"

        response = http.request(req)

        if response.code.to_i.between?(200, 299)
          Rails.logger.info("Successfully created notifications for assignment #{assignment_id}")
        else
          Rails.logger.warn("Failed to create notifications for assignment #{assignment_id}: #{response.body}")
        end
      rescue StandardError => e
        Rails.logger.error("Error when creating notifications for assignment #{assignment_id}: #{e.message}")
      end
    end
end
