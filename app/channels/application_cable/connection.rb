module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]
      return reject_unauthorized_connection if token.blank?

      access_token = Doorkeeper::AccessToken.find_by(token: token)
      return reject_unauthorized_connection if access_token.nil?

      user = Users::User.find_by(id: access_token.resource_owner_id)
      user || reject_unauthorized_connection
    end
  end
end
