require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  setup do
    @user = users(:one)
    @user_details = user_details(:one)
    session[:user_id] = @user_details
  end

  # CG - Added test "teardown" method.
  def teardown
    @user = nil
    @user_details = nil
    session[:user_id] = nil
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get index json" do
    # get(:index, { :format => 'json' })

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :index

    assert_equal 'application/json', @response.content_type
    assert_response :success

    user = JSON.parse(@response.body)
    assert_equal "Loftus", user['surname']

    # puts @request.content_type
    # puts @response.content_type
    # puts @response.body

    # get :index

    # assert_response :success
    # assert_not_nil assigns(:users)

  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { email: @user.email + 'newuser',
                            firstname: @user.firstname,
                            grad_year: @user.grad_year,
                            jobs: @user.jobs,
                            phone: @user.phone,
                            surname: @user.surname }
    end

    assert_redirected_to "#{user_path(assigns(:user))}?page=1"
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user, user: { email: @user.email, firstname: @user.firstname, grad_year: @user.grad_year, jobs: @user.jobs, phone: @user.phone, surname: @user.surname }
    assert_redirected_to "#{user_path(assigns(:user))}?page=1"
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to "#{users_path}?page=1"
  end
end
