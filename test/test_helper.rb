ENV["RAILS_ENV"] ||= "test"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start "rails" do
    add_filter "/test/"
    add_filter "/config/"
    add_filter "/vendor/"

    add_group "Models", "app/models"
    add_group "Controllers", "app/controllers"
    add_group "Services", "app/services"
    add_group "Helpers", "app/helpers"
  end
end

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
