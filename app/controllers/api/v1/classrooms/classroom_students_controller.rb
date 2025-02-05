module Api
  module V1
    module Classrooms
      class ClassroomStudentsController < ApplicationController
        include ResponseHelper
        before_action :doorkeeper_authorize!

        STUDENT_RETRIEVE_SUCCESS = "Students retrieved successfully".freeze
        STUDENT_RETRIEVE_FAIL = "Student retrieval failed".freeze
        STUDENT_ENROLLMENT_SUCCESS = "Student enrolled successfully".freeze

        def unenrolled_students
          result = ::Classrooms::GetUnenrolledStudents.call(classroom_id: params[:classroom_id])

          if result.success?
            success_response(data: result.unenrolled_students, message: STUDENT_RETRIEVE_SUCCESS)
          else
            error_response(message: result.message, status: :unprocessable_entity, error: STUDENT_RETRIEVE_FAIL)
          end
        end

        def enroll_student
          result = ::Classrooms::EnrollStudent.call(user_id: params[:user_id], email: params[:email], classroom_id: params[:classroom_id])

          if result.success?
            success_response(data: result.classroom_student, message: STUDENT_ENROLLMENT_SUCCESS, status: :created)
          else
            error_response(message: result.message, status: result.status, error: result.error)
          end
        end
      end
    end
  end
end
