module Api
  module V1
    module Classrooms
      class ClassroomsController < ApplicationController
        include ResponseHelper
        before_action :doorkeeper_authorize!

        CLASSROOM_CREATION_SUCCESS = "Classroom created successfully".freeze
        CLASSROOM_CREATION_FAIL = "Classroom creation failed".freeze
        CLASSROOMS_RETRIEVED_SUCCESS = "Classrooms retrieved successfully".freeze
        CLASSROOMS_RETRIEVAL_FAIL = "Classrooms retrieval failed".freeze
        CLASSROOM_UPDATE_SUCCESS = "Classroom updated successfully".freeze
        CLASSROOM_UPDATE_FAIL = "Classroom update failed".freeze
        CLASSROOM_DELETION_SUCCESS = "Classroom deleted successfully".freeze
        CLASSROOM_DELETION_FAIL = "Classroom deletion failed".freeze

        def create
          result = ::Classrooms::CreateClassroom.call(
            teacher_id: doorkeeper_token.resource_owner_id,
            classroom_params: classroom_params
          )

          if result.success?
            success_response(data: result.classroom, message: CLASSROOM_CREATION_SUCCESS, status: :created)
          else
            error_response(message: result.message, status: result.status, error: CLASSROOM_CREATION_FAIL)
          end
        end

        def get_classrooms
          result = ::Classrooms::GetClassrooms.call(
            teacher_id: doorkeeper_token.resource_owner_id
          )

          if result.success?
            success_response(data: result.classrooms, message: CLASSROOMS_RETRIEVED_SUCCESS)
          else
            error_response(message: result.message, status: result.status, error: CLASSROOMS_RETRIEVAL_FAIL)
          end
        end

        def update_classroom
          result = ::Classrooms::UpdateClassroom.call(
            teacher_id: doorkeeper_token.resource_owner_id,
            classroom_id: params[:id],
            classroom_params: classroom_params
          )

          if result.success?
            success_response(data: result.classroom, message: CLASSROOM_UPDATE_SUCCESS)
          else
            error_response(message: result.message, status: result.status, error: CLASSROOM_UPDATE_FAIL)
          end
        end

        def delete_classroom
          result = ::Classrooms::DeleteClassroom.call(
            teacher_id: doorkeeper_token.resource_owner_id,
            classroom_id: params[:id]
          )

          if result.success?
            success_response(data: {}, message: CLASSROOM_DELETION_SUCCESS)
          else
            error_response(message: result.message, status: result.status, error: CLASSROOM_DELETION_FAIL)
          end
        end

        def get_classroom_teacher
          result = ::Classrooms::GetClassroomTeacher.call(classroom_id: params[:classroom_id])

          if result.success?
            success_response(data: result.teacher, message: "Teacher retrieved successfully")
          else
            error_response(message: result.message, status: result.status, error: "Teacher retrieval failed")
          end
        end

        private

        def classroom_params
          params.require(:classroom).permit(:title, :subject, :class_time, days_of_week: [])
        end
      end
    end
  end
end
