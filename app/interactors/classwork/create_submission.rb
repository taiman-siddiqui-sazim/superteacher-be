module Classwork
  class CreateSubmission
    include Interactor
    include Constants::ClassworkConstants

    def call
      create_submission
    rescue StandardError => e
      context.fail!(
        message: SUBMISSION_CREATION_FAIL,
        status: :unprocessable_entity
      )
    end

    private

    def create_submission
      assignment = Assignment.find_by(id: context.assignment_id)

      unless assignment
        context.fail!(
          message: SUBMISSION_INVALID_ASSIGNMENT,
          status: :not_found
        )
      end

      submitted_at = Time.current.in_time_zone(DEFAULT_TIMEZONE)
      is_late = Submission.che ck_if_late?(submitted_at, assignment.due_date)

      submission = Submission.create!(
        assignment_id: context.assignment_id,
        user_id: context.user_id,
        file_url: context.file_url,
        submitted_at: submitted_at,
        is_late: is_late
      )

      context.submission = submission
    end
  end
end
