module Api
  module V1
    module Classrooms
      class ClassroomStudentsController < ApplicationController
        include ResponseHelper
        include Constants::ClassroomConstants
        before_action :doorkeeper_authorize!

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
            error_response(message: result.message, status: result.status, error: STUDENT_ENROLLMENT_FAIL)
          end
        end

        def students_in_classroom
          result = ::Classrooms::GetEnrolledStudents.call(classroom_id: params[:classroom_id])

          if result.success?
            success_response(data: result.students, message: STUDENT_RETRIEVE_SUCCESS)
          else
            error_response(message: result.message, status: result.status, error: STUDENT_RETRIEVE_FAIL)
          end
        end

        def unenroll_student
          result = ::Classrooms::UnenrollStudent.call(user_id: params[:user_id], classroom_id: params[:classroom_id])

          if result.success?
            success_response(data: {}, message: result.message)
          else
            error_response(message: result.message, status: result.status, error: STUDENT_ENROLLMENT_FAIL)
          end
        end

        def get_classrooms_for_student
          result = ::Classrooms::GetStudentClasses.call(user_id: doorkeeper_token.resource_owner_id)

          if result.success?
            success_response(data: result.classrooms, message: CLASSROOM_RETRIEVE_SUCCESS)
          else
            error_response(message: result.message, status: result.status, error: CLASSROOM_RETRIEVE_FAIL)
          end
        end

        def students_in_classroom
          result = ::Classrooms::GetEnrolledStudents.call(classroom_id: params[:classroom_id])

          if result.success?
            success_response(data: result.students, message: STUDENT_RETRIEVE_SUCCESS)
          else
            error_response(message: result.message, status: result.status, error: result.error)
          end
        end

        def unenroll_student
          result = ::Classrooms::UnenrollStudent.call(user_id: params[:user_id], classroom_id: params[:classroom_id])

          if result.success?
            success_response(data: {}, message: result.message)
          else
            error_response(message: result.message, status: result.status, error: STUDENT_ENROLLMENT_FAIL)
          end
        end

        def students_in_classroom
          result = ::Classrooms::GetEnrolledStudents.call(classroom_id: params[:classroom_id])

          if result.success?
            success_response(data: result.students, message: STUDENT_RETRIEVE_SUCCESS)
          else
            error_response(message: result.message, status: result.status, error: STUDENT_RETRIEVE_FAIL)
          end
        end

        def unenroll_student
          result = ::Classrooms::UnenrollStudent.call(user_id: params[:user_id], classroom_id: params[:classroom_id])

          if result.success?
            success_response(data: {}, message: result.message)
          else
            error_response(message: result.message, status: result.status, error: STUDENT_ENROLLMENT_FAIL)
          end
        end

        def get_classrooms_for_student
          result = ::Classrooms::GetStudentClasses.call(user_id: doorkeeper_token.resource_owner_id)

          if result.success?
            success_response(data: result.classrooms, message: CLASSROOM_RETRIEVE_SUCCESS)
          else
            error_response(message: result.message, status: result.status, error: CLASSROOM_RETRIEVE_FAIL)
          end
        end
      end
    end
  end
end
