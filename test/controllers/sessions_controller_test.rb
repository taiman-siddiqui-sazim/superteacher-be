require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @student = students(:one)
    @application = Doorkeeper::Application.create!(
      name: "DefaultApp",
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
      uid: ENV["DEFAULT_CLIENT_ID"],
      secret: ENV["DEFAULT_CLIENT_SECRET"]
    )
  end

  test "should login with valid credentials and student record" do
    post api_v1_login_url, params: { email: @user.email, password: "Password1!" }, as: :json
    assert_response :success
    assert_not_nil json_response["token"]
  end

  test "should not login with invalid email" do
    post api_v1_login_url, params: { email: "invalid@example.com", password: "Password1!" }, as: :json
    assert_response :unauthorized
    assert_equal "Invalid email or password", json_response["error"]
  end

  test "should not login with invalid password" do
    post api_v1_login_url, params: { email: @user.email, password: "wrongpassword" }, as: :json
    assert_response :unauthorized
    assert_equal "Invalid email or password", json_response["error"]
  end

  test "should not login if student record does not exist" do
    @student.destroy
    post api_v1_login_url, params: { email: @user.email, password: "Password1!" }, as: :json
    assert_response :unauthorized
    assert_equal "Record does not exist", json_response["error"]
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
