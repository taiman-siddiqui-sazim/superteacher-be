require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      first_name: "John",
      last_name: "Wick",
      gender: "male",
      email: "john.wick@example.com",
      password: "Password123!",
      user_type: "student"
    )
    @student = Student.create!(
      phone: "1234567890",
      address: "123 Main St",
      education_level: "school",
      medium: "english",
      year: 10,
      user: @user
    )
  end

  test "should login with valid credentials and student record" do
    post login_url, params: { email: @user.email, password: "Password123!" }, as: :json
    assert_response :success
    assert_not_nil json_response["token"]
  end

  test "should not login with invalid email" do
    post login_url, params: { email: "invalid@example.com", password: "Password123!" }, as: :json
    assert_response :unauthorized
    assert_equal "Invalid email or password", json_response["error"]
  end

  test "should not login with invalid password" do
    post login_url, params: { email: @user.email, password: "wrongpassword" }, as: :json
    assert_response :unauthorized
    assert_equal "Invalid email or password", json_response["error"]
  end

  test "should not login if student record does not exist" do
    @student.destroy
    post login_url, params: { email: @user.email, password: "Password123!" }, as: :json
    assert_response :unauthorized
    assert_equal "Record does not exist", json_response["error"]
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
