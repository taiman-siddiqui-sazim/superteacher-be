module Classwork
    class GetMaterials
      include Interactor
      include Constants::ClassworkConstants

      def call
        materials = Material.where(classroom_id: context.classroom_id)

        if materials.present?
          context.materials = materials.to_a
        else
          context.fail!(
            message: MATERIALS_RETRIEVE_FAIL,
            status: :not_found
          )
        end
      rescue StandardError => e
        context.fail!(message: e.message, status: :unprocessable_entity)
      end
    end
end
