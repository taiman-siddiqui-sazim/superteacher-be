module Classwork
    class GetMaterials
      include Interactor
      include Constants::ClassworkConstants

      def call
        materials = Material.where(classroom_id: context.classroom_id)
        context.materials = materials.to_a
      rescue StandardError => e
        context.fail!(message: e.message, status: :unprocessable_entity)
      end
    end
end
