module Classrooms
    class CreateMessage
      include Interactor
      include Constants::MessageConstants

      def call
        message = Classrooms::Message.new(
          content: context.content,
          user_id: context.user_id,
          classroom_id: context.classroom_id,
          download_url: context.download_url
        )

        unless message.save
          context.fail!(
            message: message.errors.full_messages.join(", "),
            status: :unprocessable_entity
          )
        end

        formatted_message = message.as_json(include: {
          user: {
            only: [ :id ],
            methods: [ :first_name, :last_name, :user_type ]
          }
        })

        ActionCable.server.broadcast(
          "classroom_chat_channel_#{message.classroom_id}",
          formatted_message
        )

        context.message = message
      rescue => e
        context.fail!(
          message: e.message,
          status: :internal_server_error
        )
      end
    end
end
