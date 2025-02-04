module Api
  module V1
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
        teacher_id = doorkeeper_token.resource_owner_id
        unless ::Users::User.exists?(id: teacher_id)
          return error_response(message: "Teacher not found", status: :unprocessable_entity, error: CLASSROOM_CREATION_FAIL)
        end

        classroom = Classrooms::Classroom.new(classroom_params.merge(teacher_id: teacher_id))

        if classroom.save
          success_response(data: classroom, message: CLASSROOM_CREATION_SUCCESS, status: :created)
        else
          error_response(message: classroom.errors.full_messages, status: :unprocessable_entity, error: CLASSROOM_CREATION_FAIL)
        end
      end

      def get_classrooms
        teacher_id = doorkeeper_token.resource_owner_id
        classrooms = Classrooms::Classroom.where(teacher_id: teacher_id)

        if classrooms.any?
          classrooms_data = classrooms.map do |classroom|
            {
              id: classroom.id,
              title: classroom.title,
              subject: classroom.subject,
              class_time: classroom.class_time,
              days_of_week: classroom.days_of_week,
              teacher_id: classroom.teacher_id
            }
          end
          success_response(data: classrooms_data, message: CLASSROOMS_RETRIEVED_SUCCESS)
        else
          error_response(message: "No classrooms found", status: :not_found, error: CLASSROOMS_RETRIEVAL_FAIL)
        end
      end

      def update_classroom
        teacher_id = doorkeeper_token.resource_owner_id
        unless ::Users::User.exists?(id: teacher_id)
          return error_response(message: "Teacher not found", status: :unprocessable_entity, error: CLASSROOM_UPDATE_FAIL)
        end

        classroom = Classrooms::Classroom.find_by(id: params[:id], teacher_id: teacher_id)

        if classroom.nil?
          error_response(message: "Classroom not found", status: :not_found, error: CLASSROOM_UPDATE_FAIL)
        elsif classroom.update(classroom_params)
          success_response(data: classroom, message: CLASSROOM_UPDATE_SUCCESS)
        else
          error_response(message: classroom.errors.full_messages, status: :unprocessable_entity, error: CLASSROOM_UPDATE_FAIL)
        end
      end

      def delete_classroom
        teacher_id = doorkeeper_token.resource_owner_id
        classroom = Classrooms::Classroom.find_by(id: params[:id], teacher_id: teacher_id)

        if classroom.nil?
          error_response(message: "Classroom not found", status: :not_found, error: CLASSROOM_DELETION_FAIL)
        elsif classroom.destroy
          success_response(data: {}, message: CLASSROOM_DELETION_SUCCESS)
        else
          error_response(message: classroom.errors.full_messages, status: :unprocessable_entity, error: CLASSROOM_DELETION_FAIL)
        end
      end

      private

      def classroom_params
        params.require(:classroom).permit(:title, :subject, :class_time, days_of_week: [])
      end
    end
  end
end
