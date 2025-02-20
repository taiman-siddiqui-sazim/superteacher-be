class ClassroomChatChannel < ApplicationCable::Channel
    def subscribed
      stream_from "classroom_chat_channel_#{params[:classroom_id]}"
    end

    def unsubscribed
      stop_all_streams
    end

    def receive(data)
      ActionCable.server.broadcast(
        "classroom_chat_channel_#{params[:classroom_id]}",
        data
      )
    end
end
