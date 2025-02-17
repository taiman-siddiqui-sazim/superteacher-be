module Classwork
    class GetAssignments
      include Interactor
      include Constants::ClassworkConstants

      def call
        assignments = Assignment.where(classroom_id: context.classroom_id)

        if assignments.present?
          context.assignments = assignments.to_a
        else
          context.fail!(
            message: ASSIGNMENTS_RETRIEVE_FAIL,
            status: :not_found
          )
        end
      rescue StandardError => e
        context.fail!(message: e.message, status: :unprocessable_entity)
      end
    end
end
