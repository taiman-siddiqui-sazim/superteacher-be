module Classwork
  class UpdateAssignmentFields
    include Interactor
    include Constants::ClassworkConstants

    def call
      assignment = Assignment.find_by(id: context.assignment_id)

      context.fail!(
        message: ASSIGNMENT_NOT_FOUND,
        status: :not_found
      ) unless assignment

        if assignment.assignment_type == "exam"
          current_time = Time.current.in_time_zone(DEFAULT_TIMEZONE)
          past_due_date = Submission.check_if_late?(current_time, assignment.due_date)

        if past_due_date
          context.fail!(
            message: EXAM_UPDATE_PAST_DUE,
            status: :unprocessable_entity
          )
          return
        end
        end

      original_due_date = assignment.due_date

      ActiveRecord::Base.transaction do
        unless assignment.update(context.params)
          context.fail!(
            message: assignment.errors.full_messages.join(", "),
            status: :unprocessable_entity
          )
        end

        context.due_date_changed = assignment.due_date != original_due_date

        if assignment.saved_change_to_due_date?
          assignment.submissions.each do |submission|
            is_late = Submission.check_if_late?(
              submission.submitted_at,
              assignment.due_date
            )
            submission.update!(is_late: is_late)
          end
        end

        context.assignment = assignment
      end
    rescue StandardError => e
      Rails.logger.error("Failed to update assignment: #{e.message}")
      context.fail!(
        message: e.message,
        status: :unprocessable_entity
      )
    end
  end
end
