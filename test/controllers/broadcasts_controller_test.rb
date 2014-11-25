require 'test_helper'

class BroadcastsControllerTest < ActionController::TestCase
  setup do
    @broadcast = broadcasts(:one)
    @user_details = user_details(:one)
    session[:user_id] = @user_details.id
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:broadcasts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create broadcast" do
    assert_difference('Broadcast.count') do
      post :create, broadcast: { content: @broadcast.content, user_id: @broadcast.user_id }, feeds: ["twitter"]
    end

    # assert_redirected_to broadcast_path(assigns(:broadcast))

    # CG - Updated to use root broadcasts path with pagination parameter instead of individual broadcast path. (Taken from user_controller_test.rb)
    assert_redirected_to "#{broadcasts_path(assigns(:user))}?page=1"
  end

  test "should show broadcast" do
    get :show, id: @broadcast
    assert_response :success
  end

  # CG - Removed following advice from CWL as broadcasts should not be able to be updated or edited.

  # test "should get edit" do
  #   get :edit, id: @broadcast
  #   assert_response :success
  # end
  #
  # test "should update broadcast" do
  #   patch :update, id: @broadcast, broadcast: { content: @broadcast.content, user_id: @broadcast.user_id }
  #   assert_redirected_to broadcast_path(assigns(:broadcast))
  # end

  test "should destroy broadcast" do
    assert_difference('Broadcast.count', -1) do
      delete :destroy, id: @broadcast
    end

    assert_redirected_to broadcasts_path
  end
end
