module Api
  module V1
    module Classrooms
      class ClassroomsController < ApplicationController
        include ResponseHelper
        include Constants::ClassroomConstants
        before_action :doorkeeper_authorize!

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

        def get_classrooms_for_teacher
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

        def get_teacher_by_classroom_id
          result = ::Classrooms::GetClassroomTeacher.call(classroom_id: params[:classroom_id])

          if result.success?
            success_response(data: result.teacher, message: TEACHER_RETRIEVAL_SUCCESS)
          else
            error_response(message: result.message, status: result.status, error: TEACHER_RETRIEVAL_FAIL)
          end
        end

        def get_classroom
          result = ::Classrooms::GetClassroom.call(
            classroom_id: params[:id]
          )

          if result.success?
            success_response(
              data: result.classroom,
              message: CLASSROOM_RETRIEVE_SUCCESS
            )
          else
            error_response(
              message: result.message,
              status: result.status,
              error: CLASSROOM_RETRIEVE_FAIL
            )
          end
        end

        def add_meet_link
          result = ::Classrooms::AddMeetLink.call(
            classroom_id: params[:id],
            meet_link: params[:meet_link]
          )

          if result.success?
            success_response(
              data: { meet_link: result.meet_link },
              message: MEET_LINK_ADD_SUCCESS
            )
          else
            error_response(
              message: result.message,
              status: result.status,
              error: MEET_LINK_ADD_FAIL
            )
          end
        end

        def get_meet_link
          result = ::Classrooms::GetMeetLink.call(
            classroom_id: params[:id]
          )

          if result.success?
            success_response(
              data: { meet_link: result.meet_link.meet_link },
              message: MEET_LINK_RETRIEVE_SUCCESS
            )
          else
            error_response(
              message: result.message,
              status: result.status,
              error: MEET_LINK_RETRIEVE_FAIL
            )
          end
        end

        def update_meet_link
          result = ::Classrooms::UpdateMeetLink.call(
            classroom_id: params[:id],
            meet_link: params[:meet_link]
          )

          if result.success?
            success_response(
              data: { meet_link: result.meet_link.meet_link },
              message: MEET_LINK_UPDATE_SUCCESS
            )
          else
            error_response(
              message: result.message,
              status: result.status,
              error: MEET_LINK_UPDATE_FAIL
            )
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
