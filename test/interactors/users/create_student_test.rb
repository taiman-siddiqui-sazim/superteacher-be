require "test_helper"

module Users
  class CreateStudentTest < ActiveSupport::TestCase
    fixtures :users, :students

    setup do
      @valid_user_params = {
        first_name: "John",
        last_name: "Doe",
        gender: "Male",
        email: "new.john.doe@example.com",
        password: "Password1!",
        confirm_password: "Password1!",
        user_type: "student",
        phone: "1234567890",
        address: "123 Main St",
        education_level: "School",
        medium: "English",
        year: 5
      }
    end

    test "should create user and student with valid data" do
      result = Users::CreateUser.call(user_params: ActionController::Parameters.new(@valid_user_params))

      assert result.success?
      assert result.user.persisted?
      assert result.student.persisted?
      assert_equal "new.john.doe@example.com", result.user.email
      assert_equal "1234567890", result.student.phone
    end

    test "should fail with password mismatch" do
      invalid_params = @valid_user_params.merge(confirm_password: "DifferentPassword")
      result = Users::CreateUser.call(user_params: ActionController::Parameters.new(invalid_params))

      assert result.failure?
      assert_includes result.errors, "Passwords do not match"
    end

    test "should fail when user already exists" do
      existing_user_params = @valid_user_params.merge(email: users(:one).email)
      result = Users::CreateUser.call(user_params: ActionController::Parameters.new(existing_user_params))

      assert result.failure?
      assert_includes result.errors, "User already exists"
    end

    test "should fail with invalid student data and destroy user record" do
      invalid_params = @valid_user_params.merge(phone: nil)
      result = Users::CreateUser.call(user_params: ActionController::Parameters.new(invalid_params))

      assert result.failure?
      assert_includes result.errors, "Phone can't be blank"
      assert_not User.exists?(email: invalid_params[:email])
    end
  end
end
