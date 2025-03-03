module Api
    module V1
      module Classwork
        class MaterialsController < ApplicationController
          include ResponseHelper
          include Constants::ClassworkConstants
          include FileUploadable
          before_action :doorkeeper_authorize!

          def create_material
            result = ::Classwork::CreateMaterial.call(
              params: material_params,
              classroom_id: params[:classroom_id]
            )

            unless result.success?
              return error_response(
                message: result.message,
                status: result.status,
                error: MATERIAL_CREATION_FAIL
              )
            end

            file_uploads_controller = initialize_file_uploads_controller({
              file: params[:file],
              file_url: params[:file_url]
            })
            upload_result = file_uploads_controller.upload_file

            unless upload_result[:success?]
              result.material.destroy!
              return error_response(
                message: upload_result[:message],
                status: :unprocessable_entity,
                error: upload_result[:error]
              )
            end

            result.material.update!(file_url: upload_result[:data][:file_url])

            email_result = ::Classwork::SendClassworkEmail.call(
              material: result.material
            )

            if !email_result.success?
              Rails.logger.warn("Failed to send material notification emails: #{email_result.error}")
            end

            success_response(data: result.material, message: MATERIAL_CREATION_SUCCESS)
          end

          def get_materials_by_classroom
            result = ::Classwork::GetMaterials.call(
              classroom_id: params[:classroom_id]
            )

            if result.success?
              success_response(
                data: result.materials,
                message: MATERIALS_RETRIEVE_SUCCESS
              )
            else
              error_response(
                message: result.message,
                status: result.status,
                error: ERROR_NO_MATERIALS
              )
            end
          end

          def delete_material
            material = ::Classwork::Material.find_by(id: params[:id])
            return error_response(
              message: MATERIAL_NOT_FOUND,
              status: :not_found,
              error: MATERIAL_DELETE_FAIL
            ) unless material

            file_uploads_controller = initialize_file_uploads_controller({
              file_url: material.file_url
            })
            delete_result = file_uploads_controller.delete_file

            unless delete_result[:success?]
              return error_response(
                message: delete_result[:message],
                status: :unprocessable_entity,
                error: MATERIAL_DELETE_FAIL
              )
            end

            material.destroy!
            success_response(
              data: {},
              message: MATERIAL_DELETE_SUCCESS
            )
          end

          def update_material_fields
            result = ::Classwork::UpdateMaterialFields.call(
              material_id: params[:id],
              params: update_material_params
            )

            if result.success?
              success_response(
                data: result.material,
                message: MATERIAL_UPDATE_SUCCESS
              )
            else
              error_response(
                message: result.message,
                status: result.status,
                error: MATERIAL_UPDATE_FAIL
              )
            end
          end

          def update_file
            material = ::Classwork::Material.find_by(id: params[:id])
            return error_response(
              message: MATERIAL_NOT_FOUND,
              status: :not_found,
              error: MATERIAL_CREATION_FAIL
            ) unless material

            old_file_url = material.file_url

            file_uploads_controller = initialize_file_uploads_controller({
              file: params[:file],
              file_url: params[:file_url]
            })
            upload_result = file_uploads_controller.upload_file

            unless upload_result[:success?]
              return error_response(
                message: upload_result[:message],
                status: :unprocessable_entity,
                error: FILE_UPDATE_FAIL
              )
            end

            material.update!(file_url: upload_result[:data][:file_url])

            file_uploads_controller = initialize_file_uploads_controller({
              file_url: old_file_url
            })
            delete_result = file_uploads_controller.delete_file

            if delete_result[:success?]
              message = FILE_UPDATE_SUCCESS
            else
              Rails.logger.warn("Warning: Failed to delete old file at #{old_file_url}")
              message = FILE_UPDATE_SUCCESS
            end

            success_response(data: material, message: message)
          end

          private

          def material_params
            params.require(:material).permit(:title, :instruction)
          end

          def update_material_params
            params.require(:material).permit(:title, :instruction)
          end
        end
      end
    end
end
