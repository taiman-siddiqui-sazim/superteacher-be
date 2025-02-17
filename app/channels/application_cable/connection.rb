module ApplicationCable
    class Connection < ActionCable::Connection::Base
      identified_by :current_user

      def connect
        self.current_user = find_verified_user
      end

      private

      def find_verified_user
        token = request.params[:token]
        access_token = Doorkeeper::AccessToken.find_by(token: token)
        user = Users::User.find(access_token.resource_owner_id)
        user || reject_unauthorized_connection
      end
    end
end
