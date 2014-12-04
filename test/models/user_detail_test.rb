require 'test_helper'

class UserDetailTest < ActiveSupport::TestCase

  fixtures :user_details

  test "set password" do
    user_detail = UserDetail.new

    user_detail.password=("password")

    assert_equal "password", user_detail.password

  end

  test "prepare password" do

    @user_detail = UserDetail.new

    @user_detail.password=("password")

    @user_detail.instance_eval{ prepare_password }

  end

end
