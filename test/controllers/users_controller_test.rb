require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  setup do
    @user_admin = users(:userone)
    @user_admin_details = user_details(:userone)

    @user_normal = users(:usertwo)
    @user_normal_details = user_details(:usertwo)

    @user_fake = users(:userthree)
    @user_fake_details = user_details(:userthree)

    session[:user_id] = @user_admin_details
  end

  # CG - Added test "teardown" method.
  def teardown
    @user_admin = nil
    @user_admin_details = nil

    @user_normal = nil
    @user_normal_details = nil

    session[:user_id] = nil
  end

  test "should session access denied" do

    session[:user_id] = nil

    get :index

    assert_redirected_to "#{new_session_path}"

  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get index json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :index

    assert_equal 'application/json', @response.content_type
    assert_response :success

    parsedUser = json_response[0]

    assert_equal "Administrator", parsedUser['firstname']
    assert_equal "Account", parsedUser['surname']

    # puts @request.content_type
    # puts @response.content_type
    # puts @response.body

    # get :index

    # assert_response :success
    # assert_not_nil assigns(:users)

  end

  test "should not get index json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("fake1:test123")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :index

    assert_equal 'application/json', @response.content_type

    assert_response :unauthorized

  end


  test "should get index non admin json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("clg11:test123")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :index

    assert_response :unauthorized

    parsedError = json_response["errors"]

    assert_equal 1, parsedError.count

    assert_equal "You must be admin to do that", parsedError[0]

  end

  test "should get index non admin" do

    session[:user_id] = @user_normal_details

    get :index

    assert_response :found

    assert_redirected_to "#{root_url}"

    # assert_equal "You must be admin to do that", parsedError[0]

  end

  test "should get index no locale" do

    get :index, locale: "fr"

    # puts @response.body

    assert_select "span.flash_message", {:text => "en translation not available"}

  end

  test "should deny access json incorrect credentials" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("username:password")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :index

    assert_equal 'application/json', @response.content_type
    assert_response :unauthorized

  end

  test "should deny access json missing credentials" do

    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :index

    assert_equal 'application/json', @response.content_type
    assert_response :unauthorized

  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { email: @user_admin.email + 'newuser',
                            firstname: @user_admin.firstname,
                            grad_year: @user_admin.grad_year,
                            jobs: @user_admin.jobs,
                            phone: @user_admin.phone,
                            surname: @user_admin.surname }
    end

    assert_redirected_to "#{user_path(assigns(:user))}?page=1"
  end

  test "should error create user json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    post :create, user: { email: @user_admin.email + 'newuser',
      firstname: @user_admin.firstname,
      grad_year: 2016,
      jobs: @user_admin.jobs,
      phone: @user_admin.phone,
      surname: @user_admin.surname }

    assert_response :bad_request

    parsedError = json_response["errors"]

    assert_equal 1, parsedError.count

    assert_equal "Grad year must be less than or equal to 2014", parsedError[0]

  end

  test "should search user" do

    # CG - Perform serach for user with a surname that contains "god"
    get :search, surname: 1, q: "god"

    # puts @response.body

    assert_response :success

    #  CG - Check that the HTML respnse comes with a table with one row in it (for the single user that should have been returned)
    assert_select "tbody" do
      assert_select "tr", 1
    end

    # CG - Check that the HTML table ceontains <TD> elements somewhere that contain "Goddard" and "Connor" - No particular order.
    assert_select "tbody" do
      assert_select "tr.list-line-odd" do
        assert_select "td", {:text => "Goddard"}
        assert_select "td", {:text => "Connor"}
      end
    end

  end

  test "should search user json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    # CG - Perform serach for user with a surname that contains "god"
    get :search, surname: 1, q: "god", client: 1

    assert_response :success

    parsedUser = json_response[0]

    assert_equal 1, json_response.count

    assert_equal "Connor", parsedUser['firstname']
    assert_equal "Goddard", parsedUser['surname']

  end

  test "should show user" do
    get :show, id: @user_admin
    assert_response :success
  end

  test "should redirect access show user" do

    session[:user_id] = @user_normal_details

    get :show, id: @user_admin

    assert_response :found
  end

  test "should deny access show user json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("clg11:test123")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :show, id: @user_admin

    assert_response :unauthorized

  end

  test "should find no user show user" do

    get :show, id: 1000

    assert_redirected_to "#{users_url}?page=1"

  end

  test "should find no user show user json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

      get :show, id: 1000

      assert_response :not_found

      parsedError = json_response["errors"]

      assert_equal 1, parsedError.count

      assert_equal "User does not exist", parsedError[0]

  end

  test "should get edit" do
    get :edit, id: @user_admin
    assert_response :success
  end

  test "should get deny access edit user" do

    session[:user_id] = @user_normal_details

    get :edit, id: @user_admin

    assert_response :found

    assert_redirected_to "#{home_url}"

  end

  test "should get deny access edit user json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("clg11:test123")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :edit, id: @user_admin
    assert_response :unprocessable_entity

  end

  test "should update user" do
    patch :update, id: @user_admin, user: { email: @user_admin.email, firstname: @user_admin.firstname, grad_year: @user_admin.grad_year, jobs: @user_admin.jobs, phone: @user_admin.phone, surname: @user_admin.surname }
    assert_redirected_to "#{user_path(assigns(:user))}?page=1"
  end

  test "should patch deny access update user json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("clg11:test123")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    patch :update, id: @user_admin, user: { email: @user_admin.email, firstname: @user_admin.firstname, grad_year: @user_admin.grad_year, jobs: @user_admin.jobs, phone: @user_admin.phone, surname: @user_admin.surname }
    assert_response :unprocessable_entity

  end

  test "should error patch update user json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    patch :update, id: @user_admin, user: { grad_year: 1900 }

    assert_response :unprocessable_entity

    parsedError = json_response["errors"]

    assert_equal 1, parsedError.count

    assert_equal "Grad year must be greater than or equal to 1970", parsedError[0]

  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user_admin
    end

    assert_redirected_to "#{users_path}?page=1"
  end
end
