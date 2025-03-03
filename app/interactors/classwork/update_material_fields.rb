module Classwork
    class UpdateMaterialFields
      include Interactor
      include Constants::ClassworkConstants

      def call
        material = Material.find_by(id: context.material_id)

        context.fail!(
          message: MATERIAL_NOT_FOUND,
          status: :not_found
        ) unless material

        ActiveRecord::Base.transaction do
          unless material.update(context.params)
            context.fail!(
              message: material.errors.full_messages.join(", "),
              status: :unprocessable_entity
            )
          end

          context.material = material
        end
      rescue StandardError => e
        Rails.logger.error("Failed to update material: #{e.message}")
        context.fail!(
          message: e.message,
          status: :unprocessable_entity
        )
      end
    end
end
