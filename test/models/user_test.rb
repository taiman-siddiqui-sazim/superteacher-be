require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should be invalid without a first_name" do
    @user.first_name = nil
    assert_not @user.valid?
  end

  test "should be invalid with a first_name longer than 50 characters" do
    @user.first_name = "a" * 51
    assert_not @user.valid?
  end

  test "should be invalid without a last_name" do
    @user.last_name = nil
    assert_not @user.valid?
  end

  test "should be invalid with a last_name longer than 50 characters" do
    @user.last_name = "a" * 51
    assert_not @user.valid?
  end

  test "should be invalid without a gender" do
    @user.gender = nil
    assert_not @user.valid?
  end

  test "should be invalid with an invalid gender" do
    @user.gender = "invalid_gender"
    assert_not @user.valid?
  end

  test "should be invalid without an email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "should be invalid with an invalid email" do
    @user.email = "invalid_email@"
    assert_not @user.valid?
  end

  test "should be invalid with a duplicate email" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email
    assert_not duplicate_user.valid?
  end

  test "should be invalid without a password" do
    @user.password = nil
    assert_not @user.valid?
  end

  test "should be invalid with a short password" do
    @user.password = "short"
    assert_not @user.valid?
  end

  test "should be invalid with a password missing a lowercase letter" do
    @user.password = "PASSWORD1!"
    assert_not @user.valid?
  end

  test "should be invalid with a password missing an uppercase letter" do
    @user.password = "password1!"
    assert_not @user.valid?
  end

  test "should be invalid with a password missing a digit" do
    @user.password = "Password!"
    assert_not @user.valid?
  end

  test "should be invalid with a password missing a special character" do
    @user.password = "Password1"
    assert_not @user.valid?
  end

  test "should be invalid without a user_type" do
    @user.user_type = nil
    assert_not @user.valid?
  end

  test "should be invalid with an invalid user_type" do
    @user.user_type = "invalid_type"
    assert_not @user.valid?
  end
<<<<<<< HEAD
=======
  
  test "should be invalid without a student record if user_type is student" do
    @user.user_type = 'student'
    @user.student = nil
    assert_not @user.valid?
  end
end
>>>>>>> 87ac406 (feat(st-3): create user and student models with validations and tests)
