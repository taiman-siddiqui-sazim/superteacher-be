require "test_helper"

module Teachers
  class VerifyTeacherTest < ActiveSupport::TestCase
    def setup
      @valid_email = "teacher@example.com"
      @valid_unique_code = "123456"
      @invalid_unique_code = "654321"
      @unique_code_record = UniqueCode.create(email: @valid_email, unique_code: @valid_unique_code, attempts_left: 3)
    end

    def teardown
      @unique_code_record.destroy
    end

    test "should fail when unique code is not found" do
      result = VerifyTeacher.call(email: "nonexistent@example.com", unique_code: @valid_unique_code, user_params: {})

      assert_not result.success?
      assert_equal VerifyTeacher::UNIQUE_CODE_NOT_FOUND, result.message
      assert_equal :not_found, result.status
    end

    test "should fail when unique code is invalid" do
      result = VerifyTeacher.call(email: @valid_email, unique_code: @invalid_unique_code, user_params: {})

      assert_not result.success?
      assert_equal "#{VerifyTeacher::INVALID_UNIQUE_CODE}2", result.message
      assert_equal :unprocessable_entity, result.status
      assert_equal 2, @unique_code_record.reload.attempts_left
    end

    test "should fail when no more attempts are left" do
      @unique_code_record.update(attempts_left: 1)
      result = VerifyTeacher.call(email: @valid_email, unique_code: @invalid_unique_code, user_params: {})

      assert_not result.success?
      assert_equal VerifyTeacher::NO_MORE_ATTEMPTS, result.message
      assert_equal :unprocessable_entity, result.status
      assert_nil UniqueCode.find_by(email: @valid_email)
    end

    test "should succeed when unique code is valid" do
      user_params = { first_name: "John", last_name: "Doe", unique_code: @valid_unique_code }
      result = VerifyTeacher.call(email: @valid_email, unique_code: @valid_unique_code, user_params: user_params)

      assert result.success?
      assert_equal user_params.except(:unique_code), result.user_params
      assert_equal 3, @unique_code_record.reload.attempts_left
    end

    test "should decrement attempts left after invalid attempt" do
      initial_attempts_left = @unique_code_record.attempts_left

      VerifyTeacher.call(email: @valid_email, unique_code: @invalid_unique_code, user_params: {})
      assert_equal initial_attempts_left - 1, @unique_code_record.reload.attempts_left

      VerifyTeacher.call(email: @valid_email, unique_code: @invalid_unique_code, user_params: {})
      assert_equal initial_attempts_left - 2, @unique_code_record.reload.attempts_left
    end
  end
end
