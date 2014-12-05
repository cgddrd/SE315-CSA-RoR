require 'test_helper'

class BroadcastsControllerTest < ActionController::TestCase
  setup do
    @broadcast = broadcasts(:one)
    @user_details = user_details(:userone)
    @feed = feeds(:feedone)

    # @broadcast_feed = broadcasts_feeds(:one)

    session[:user_id] = @user_details.id
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:broadcasts)

    # CG - We should have Twitter and RSS feeds appearing for the first broadcast (based on the sample data within 'broadcasts_feeds.yml')
    assert_select "td", {:text => "Twitter, Rss"}


  end

  test "should get index json all broadcasts" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :index

    parsedBroadcasts = json_response

    assert_equal 2, parsedBroadcasts.count

    assert_response :success

    assert_not_nil assigns(:broadcasts)

  end

  test "should reject user get index json all broadcasts" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("fake:user")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :index

    assert_response :unauthorized

    assert_equal "HTTP Basic: Access denied.\n", @response.body

  end

  test "should get index rss all broadcasts" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::RSS
    @request.headers['Content-Type'] = Mime::RSS.to_s

    get :index

    assert_response :success

    assert_not_nil assigns(:broadcasts)

    assert_select "rss", {:version => "2.0"}

    assert_select "channel", 1

    assert_select "item", 2

    assert_select "item" do
      assert_select "title", {:text => "MyText1"}
      assert_select "title", {:text => "MyText2"}
      assert_select "description", {:text => "MyText1"}
      assert_select "description", {:text => "MyText2"}
    end

  end

  test "should reject user get index rss all broadcasts" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("fake:user")}"
    @request.headers['Accept'] = Mime::RSS
    @request.headers['Content-Type'] = Mime::RSS.to_s

    get :index

    assert_response :unauthorized

    assert_equal "HTTP Basic: Access denied.\n", @response.body

  end

  test "should get index atom all broadcasts" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = "application/atom+xml"
    @request.headers['Content-Type'] = "application/atom+xml"

    get :index

    assert_response :success

    assert_not_nil assigns(:broadcasts)

    assert_select "feed", {:xmlns => "http://www.w3.org/2005/Atom"}

    assert_select "entry", 2

    assert_select "entry" do
      assert_select "content", {:text => "MyText1"}
      assert_select "content", {:text => "MyText2"}
    end

  end

  test "should reject user get index atom all broadcasts" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("fake:user")}"
    @request.headers['Accept'] = "application/atom+xml"
    @request.headers['Content-Type'] = "application/atom+xml"

    get :index

    assert_response :unauthorized

    assert_equal "HTTP Basic: Access denied.\n", @response.body

  end

  test "should get index json paginated page1" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :index, per_page: 1, page: 1

    parsedBroadcasts = json_response

    assert_equal 1, parsedBroadcasts.count

    assert_response :success

    assert_equal "MyText1", parsedBroadcasts[0]["content"]

    assert_not_nil assigns(:broadcasts)

  end

  test "should get index json paginated page2" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :index, per_page: 1, page: 2

    parsedBroadcasts = json_response

    assert_equal 1, parsedBroadcasts.count

    assert_response :success

    assert_equal "MyText2", parsedBroadcasts[0]["content"]

    assert_not_nil assigns(:broadcasts)

  end

  test "should get index rss paginated page1" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::RSS
    @request.headers['Content-Type'] = Mime::RSS.to_s

    get :index, per_page: 1, page: 1

    assert_response :success

    assert_not_nil assigns(:broadcasts)

    assert_select "rss", {:version => "2.0"}

    assert_select "channel", 1

    assert_select "item", 1

    assert_select "title", {:text => "MyText1"}
    assert_select "description", {:text => "MyText1"}


  end

  test "should get index rss paginated page2" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::RSS
    @request.headers['Content-Type'] = Mime::RSS.to_s

    get :index, per_page: 1, page: 2

    assert_response :success

    assert_select "rss", {:version => "2.0"}

    assert_select "channel", 1

    assert_select "item", 1


    assert_select "title", {:text => "MyText2"}
    assert_select "description", {:text => "MyText2"}


  end

  test "should get index atom paginated page1" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = "application/atom+xml"
    @request.headers['Content-Type'] = "application/atom+xml"

    get :index, per_page: 1, page: 1

    assert_response :success

    assert_not_nil assigns(:broadcasts)

    assert_select "feed", {:xmlns => "http://www.w3.org/2005/Atom"}

    assert_select "entry", 1

    assert_select "content", {:text => "MyText1"}

  end

  test "should get index atom paginated page2" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = "application/atom+xml"
    @request.headers['Content-Type'] = "application/atom+xml"

    get :index, per_page: 1, page: 2

    assert_response :success

    assert_select "feed", {:xmlns => "http://www.w3.org/2005/Atom"}

    assert_select "entry", 1

    assert_select "content", {:text => "MyText2"}

  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create broadcast" do

    assert_difference('Broadcast.count') do
      post :create, broadcast: { content: @broadcast.content }, feeds: {xml: 1}
    end

    # CG - Updated to use root broadcasts path with pagination parameter instead of individual broadcast path. (Taken from user_controller_test)
    assert_redirected_to "#{broadcasts_path}?page=1"

  end

  test "should create broadcast email json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    assert_difference('Broadcast.count') do
      post :create, broadcast: { content: @broadcast.content }, feeds: {email: 1}
    end

  end

  test "should create broadcast rss json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    assert_difference('Broadcast.count') do
      post :create, broadcast: { content: @broadcast.content }, feeds: {RSS: 1}
    end

    parsedBroadcasts = json_response

    assert_response :success

    assert_equal "MyText1", parsedBroadcasts["content"]

  end

  test "should create broadcast atom json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    assert_difference('Broadcast.count') do
      post :create, broadcast: { content: @broadcast.content }, feeds: {atom: 1}
    end

    parsedBroadcasts = json_response

    assert_response :success

    assert_equal "MyText1", parsedBroadcasts["content"]

  end

  test "should create broadcast twitter multiple post error" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    assert_difference('Broadcast.count') do
      post :create, broadcast: { content: @broadcast.content }, feeds: {xml: 1, twitter: 1}
    end

    assert_response :created

    post :create, broadcast: { content: @broadcast.content }, feeds: {xml: 1, twitter: 1}

    assert_response :created

    parsedError = json_response["errors"]["feed_errors"]

    assert_equal 1, parsedError.count

    assert_equal "twitter", parsedError[0]["feed"]
    assert_equal "403", parsedError[0]["code"]
    assert_equal "Forbidden", parsedError[0]["message"]

    # CG - Updated to use root broadcasts path with pagination parameter instead of individual broadcast path. (Taken from user_controller_test)
    # assert_redirected_to "#{broadcasts_path}?page=1"

  end

  test "should create broadcast rss" do

    # CG - Should get exception if you try to create a new broadcast using an 'RSS' request.
    assert_raises(ActionController::UnknownFormat) {

      @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
      @request.headers['Accept'] = Mime::RSS
      @request.headers['Content-Type'] = Mime::RSS.to_s

      assert_difference('Broadcast.count') do
        post :create, broadcast: { content: @broadcast.content }, feeds: {rss: 1}
      end

      assert_response :created

      assert_select "channel" do
        assert_select "item", 3
      end

      assert_select "channel" do
        assert_select "item" do
          assert_select "title", {:text => "MyText2"}
          assert_select "title", {:text => "MyText1"}
        end
      end

    }

  end

  test "should create broadcast atom" do

    # CG - Should get exception if you try to create a new broadcast using an 'ATOM' request.
    assert_raises(ActionController::UnknownFormat) {

      @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
      @request.headers['Accept'] = "application/atom+xml"
      @request.headers['Content-Type'] = "application/atom+xml"

      assert_difference('Broadcast.count') do
        post :create, broadcast: { content: @broadcast.content }, feeds: {atom: 1}
      end

      assert_response :created

      assert_select "feed", {:xmlns => "http://www.w3.org/2005/Atom"}

      assert_select "entry", 3

      assert_select "entry" do
        assert_select "content", {:text => "MyText1"}
        assert_select "content", {:text => "MyText2"}
      end

  }

  end

  test "should show broadcast" do
    get :show, id: @broadcast
    assert_response :success
  end

  test "should find no broadcast show broadcast" do

    get :show, id: 1000

    assert_redirected_to "#{broadcasts_url}"

  end

  test "should find no broadcast show broadcast json" do

    @request.headers['Authorization'] = "Basic #{Base64.encode64("admin:taliesin")}"
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    get :show, id: 1000

    assert_response :not_found

    parsedError = json_response["errors"]

    assert_equal 1, parsedError.count

    assert_equal "Broadcast does not exist", parsedError[0]

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
