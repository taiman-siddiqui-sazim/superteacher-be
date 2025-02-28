module Classwork
    class UpdateSubmission
      include Interactor
      include Constants::ClassworkConstants

      def call
        update_submission
      rescue StandardError => e
        context.fail!(
          message: SUBMISSION_UPDATE_FAIL,
          status: :unprocessable_entity
        )
      end

      private

      def update_submission
        submitted_at = Time.current.in_time_zone(DEFAULT_TIMEZONE)
        is_late = Submission.check_if_late?(submitted_at, context.submission.assignment.due_date)

        context.submission.update!(
          file_url: context.file_url,
          submitted_at: submitted_at,
          is_late: is_late
        )
      end
    end
end
