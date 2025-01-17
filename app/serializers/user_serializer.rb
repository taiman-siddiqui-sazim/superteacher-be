class UserSerializer < Panko::Serializer
    attributes :id, :first_name, :last_name, :gender, :email, :user_type

    def user_type
      object.user_type.upcase
    end
end
