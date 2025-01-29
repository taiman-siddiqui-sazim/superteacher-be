class UserAuthenticationService
    def self.authenticate(email, password)
      user = Users::User.find_by(email: email)
      user if user&.authenticate(password)
    end

    def self.digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
end
