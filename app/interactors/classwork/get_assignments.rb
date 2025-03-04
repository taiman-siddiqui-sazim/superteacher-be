module Classwork
  class GetAssignments
    include Interactor
    include Constants::ClassworkConstants

    def call
      assignments = Assignment.where(classroom_id: context.classroom_id)
      context.assignments = assignments.to_a
    rescue StandardError => e
      context.fail!(message: e.message, status: :unprocessable_entity)
    end
  end
end
