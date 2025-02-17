module Classrooms
    class GetMessages
      include Interactor

      def call
        messages = Classrooms::Message.where(classroom_id: context.classroom_id)
                      .includes(:user)
                      .order(created_at: :asc)

        formatted_messages = messages.map do |message|
          message.as_json(include: {
            user: {
              only: [ :id ],
              methods: [ :first_name, :last_name, :user_type ]
            }
          })
        end

        context.messages = formatted_messages
      rescue => e
        context.fail!(
          message: e.message,
          status: :internal_server_error
        )
      end
    end
end
