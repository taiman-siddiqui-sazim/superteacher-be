module Classwork
    class GetSubmissions
      include Interactor
      include Constants::ClassworkConstants

      def call
        submissions = Submission.for_assignment(context.assignment_id)
                              .includes(:user)

        if submissions.empty?
          context.fail!(
            message: NO_SUBMISSIONS_FOUND,
            status: :not_found
          )
        end

        context.submissions = submissions.map { |submission| submission_with_user(submission) }
      end

      private

      def submission_with_user(submission)
        {
          id: submission.id,
          assignment_id: submission.assignment_id,
          user_id: submission.user_id,
          file_url: submission.file_url,
          submitted_at: submission.submitted_at,
          is_late: submission.is_late,
          user: {
            first_name: submission.user.first_name,
            last_name: submission.user.last_name,
            email: submission.user.email
          }
        }
      end
    end
end
