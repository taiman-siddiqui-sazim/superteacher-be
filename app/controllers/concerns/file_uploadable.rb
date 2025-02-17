module FileUploadable
    extend ActiveSupport::Concern

    included do
      require_dependency "api/v1/classwork/file_uploads_controller"
    end

    private

    def initialize_file_uploads_controller(controller_params)
      controller = Api::V1::Classwork::FileUploadsController.new
      controller.request = request
      controller.response = response
      controller.params = controller_params
      controller
    end
end
