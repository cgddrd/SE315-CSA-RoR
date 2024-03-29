# CG - Add simple test coverage gem 'simplecov'. - Must be at the top of the file in order to track controllers as well.
require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'rails/all'
require 'base64'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # CG - Added 'helper' function to parse JSON responses returned by the controllers. 
  def json_response
    ActiveSupport::JSON.decode @response.body
  end

end
