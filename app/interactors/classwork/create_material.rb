module Classwork
    class CreateMaterial
      include Interactor

      def call
        create_material
      rescue StandardError => e
        context.fail!(message: e.message, status: :unprocessable_entity)
      end

      private

      def create_material
        material = Material.create!(
          title: context.params[:title],
          instruction: context.params[:instruction],
          file_url: context.params[:file_url],
          classroom_id: context.classroom_id
        )

        context.material = material
      end
    end
end
