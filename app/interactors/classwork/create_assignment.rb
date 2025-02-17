module Classwork
    class CreateAssignment
      include Interactor

      def call
        create_assignment
      rescue StandardError => e
        context.fail!(message: e.message, status: :unprocessable_entity)
      end

      private

      def create_assignment
        assignment = Assignment.create!(
          title: context.params[:title],
          instruction: context.params[:instruction],
          due_date: context.params[:due_date],
          file_url: context.params[:file_url],
          assignment_type: context.params[:assignment_type],
          classroom_id: context.classroom_id
        )

        context.assignment = assignment
      end
    end
end
