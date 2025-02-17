module Api
    module V1
      module Classrooms
        class ChatChannel < ApplicationCable::Channel
          def subscribed
            stream_from "classroom_chat_#{params[:classroom_id]}"
          end

          def unsubscribed
            stop_all_streams
          end

          def receive(data)
            ActionCable.server.broadcast(
              "classroom_chat_#{params[:classroom_id]}",
              data
            )
          end
        end
      end
    end
end
