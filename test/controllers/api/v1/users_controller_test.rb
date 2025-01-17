require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @application = Doorkeeper::Application.create!(
      name: ENV["DOORKEEPER_APP_NAME"],
      redirect_uri: ENV["DOORKEEPER_REDIRECT_URI"],
      uid: ENV["DOORKEEPER_CLIENT_ID"],
      secret: ENV["DOORKEEPER_CLIENT_SECRET"]
    )
    @token = Doorkeeper::AccessToken.create!(
      resource_owner_id: @user.id,
      application_id: @application.id,
      expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
      scopes: ""
    )
  end

  test "should get current user data with valid token" do
    get api_v1_users_me_url, headers: { Authorization: "Bearer #{@token.token}" }, as: :json
    assert_response :success
    assert_equal 200, json_response["statusCode"]
    assert_equal "User data retrieved successfully", json_response["message"]
    assert_equal @user.id, json_response["data"]["id"]
    assert_equal @user.first_name, json_response["data"]["first_name"]
    assert_equal @user.last_name, json_response["data"]["last_name"]
    assert_equal @user.gender, json_response["data"]["gender"]
    assert_equal @user.email, json_response["data"]["email"]
    assert_equal @user.user_type.upcase, json_response["data"]["user_type"]
  end

  test "should not get user data with invalid token" do
    get api_v1_users_me_url, headers: { Authorization: "Bearer invalid_token" }, as: :json
    assert_response :unauthorized
  end

  test "should not get user data without token" do
    get api_v1_users_me_url, as: :json
    assert_response :unauthorized
  end

  private

  def json_response
    return {} if response.body.blank?
    JSON.parse(response.body)
  end
end
