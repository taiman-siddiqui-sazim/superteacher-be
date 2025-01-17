module ResponseHelper
  def success_response(data:, message:, status: :ok)
    response = {
      statusCode: Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
      message: message,
      data: data
    }
    render json: response, status: status
  end

  def error_response(message:, status:, error:)
    response = {
      statusCode: Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
      message: Array(message),
      error: error
    }
    render json: response, status: status
  end
end
