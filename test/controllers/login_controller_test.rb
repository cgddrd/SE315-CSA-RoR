# CG - New functional test class created for the 'LoginController' Rails controller.

require 'test_helper'

class LoginControllerTest < ActionController::TestCase

  setup do
    @user_admin = users(:userone)
    @user_admin_details = user_details(:userone)

    @user_normal = users(:usertwo)
    @user_normal_details = user_details(:usertwo)

    @user_fake = users(:userthree)
    @user_fake_details = user_details(:userthree)
  end

  # CG - Added test "teardown" method.
  def teardown
    @user_admin = nil
    @user_admin_details = nil

    @user_normal = nil
    @user_normal_details = nil
  end

  test "should login granted access admin user" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("#{@user_admin_details.login}:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :check_login

    assert_response :success

    parsedLoginResponse = json_response

    assert_equal 1, parsedLoginResponse["id"]
    assert_equal true, parsedLoginResponse["logged_in"]
    assert_equal true, parsedLoginResponse["is_admin"]

  end

  test "should login granted access non admin user" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("#{@user_normal_details.login}:test123")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :check_login

    assert_response :success

    parsedLoginResponse = json_response

    assert_equal 2, parsedLoginResponse["id"]
    assert_equal true, parsedLoginResponse["logged_in"]
    assert_equal false, parsedLoginResponse["is_admin"]

  end


  test "should login no access" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("#{@user_fake_details.login}:fakepass")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :check_login

    assert_response :unauthorized

  end

end
