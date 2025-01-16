require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @student = students(:one)
    @application = Doorkeeper::Application.create!(
      name: ENV["DOORKEEPER_APP_NAME"],
      redirect_uri: ENV["DOORKEEPER_REDIRECT_URI"],
      uid: ENV["DOORKEEPER_CLIENT_ID"],
      secret: ENV["DOORKEEPER_CLIENT_SECRET"]
    )
  end

  test "should login with valid credentials and student record" do
    post api_v1_login_url, params: { email: @user.email, password: "Password1!" }, as: :json
    assert_response :success
    assert_equal 200, json_response["statusCode"]
    assert_equal "Authentication successful", json_response["message"]
    assert_not_nil json_response["data"]["accessToken"]
    assert_equal @user.id, json_response["data"]["user"]["id"]
    assert_equal @user.first_name, json_response["data"]["user"]["first_name"]
    assert_equal @user.last_name, json_response["data"]["user"]["last_name"]
    assert_equal @user.gender, json_response["data"]["user"]["gender"]
    assert_equal @user.email, json_response["data"]["user"]["email"]
    assert_equal @user.user_type.upcase, json_response["data"]["user"]["user_type"]
  end

  test "should not login with invalid email" do
    post api_v1_login_url, params: { email: "invalid@example.com", password: "Password1!" }, as: :json
    assert_response :unauthorized
    assert_equal 401, json_response["data"]["statusCode"]
    assert_equal "Invalid credentials", json_response["data"]["message"]
    assert_equal "Unauthorized", json_response["data"]["error"]
  end

  test "should not login with invalid password" do
    post api_v1_login_url, params: { email: @user.email, password: "wrongpassword" }, as: :json
    assert_response :unauthorized
    assert_equal 401, json_response["data"]["statusCode"]
    assert_equal "Invalid credentials", json_response["data"]["message"]
    assert_equal "Unauthorized", json_response["data"]["error"]
  end

  test "should not login if student record does not exist" do
    @student.destroy
    post api_v1_login_url, params: { email: @user.email, password: "Password1!" }, as: :json
    assert_response :unauthorized
    assert_equal 401, json_response["data"]["statusCode"]
    assert_equal "Invalid credentials", json_response["data"]["message"]
    assert_equal "Unauthorized", json_response["data"]["error"]
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
