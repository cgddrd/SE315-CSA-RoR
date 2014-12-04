require 'test_helper'

class BroadcastTest < ActiveSupport::TestCase

  fixtures :broadcasts
  fixtures :users
  fixtures :user_details

  setup do
    @broadcast = broadcasts(:one)
  end

  test "broadcast to_s" do
    assert_equal "id: 1 content: MyText1 user: 1", @broadcast.to_s
  end

end
#
