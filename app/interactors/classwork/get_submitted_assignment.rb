module Classwork
  class GetSubmittedAssignment
    include Interactor
    include Constants::ClassworkConstants

    def call
      submission = Submission.find_by(
        assignment_id: context.assignment_id,
        user_id: context.user_id
      )

      unless submission
        context.fail!(
          message: SUBMISSION_NOT_FOUND,
          status: :not_found
        )
      end

      context.submission = permitted_attributes(submission)
    end

    private

    def permitted_attributes(submission)
      submission.slice(
        :id,
        :assignment_id,
        :user_id,
        :file_url,
        :submitted_at,
        :is_late
      )
    end
  end
end
