require "test_helper"

module Users
  class CreateTeacherTest < ActiveSupport::TestCase
    fixtures :users, :teachers

    setup do
      @valid_user_params = {
        first_name: "Jane",
        last_name: "Doe",
        gender: "Female",
        email: "new.jane.doe@example.com",
        password: "Password1!",
        confirm_password: "Password1!",
        user_type: "teacher",
        major_subject: "Mathematics",
        subjects: [ "Algebra", "Geometry" ],
        highest_education: "PhD"
      }
    end

    test "should create user and teacher with valid data" do
      result = Users::CreateUser.call(user_params: ActionController::Parameters.new(@valid_user_params))

      assert result.success?
      assert result.user.persisted?
      assert result.teacher.persisted?
      assert_equal "new.jane.doe@example.com", result.user.email
      assert_equal "Mathematics", result.teacher.major_subject
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

    test "should fail with invalid user type and destroy user record" do
      invalid_params = @valid_user_params.merge(user_type: "invalid_type")
      result = Users::CreateUser.call(user_params: ActionController::Parameters.new(invalid_params))

      assert result.failure?
      assert_not User.exists?(email: invalid_params[:email])
    end

    test "should fail with invalid teacher data and destroy user record" do
      invalid_params = @valid_user_params.merge(major_subject: nil)
      result = Users::CreateUser.call(user_params: ActionController::Parameters.new(invalid_params))

      assert result.failure?
      assert_includes result.errors, "Major subject can't be blank"
      assert_not User.exists?(email: invalid_params[:email])
    end
  end
end
