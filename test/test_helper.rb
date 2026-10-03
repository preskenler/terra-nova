ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in a single process by default: the shared MySQL user cannot
    # create the extra per-worker databases. Override with PARALLEL_WORKERS.
    parallelize(workers: Integer(ENV.fetch("PARALLEL_WORKERS", 1)))

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Helpers for testing mailers and background jobs.
    include ActiveJob::TestHelper
    include ActionMailer::TestHelper
  end
end

# Devise helpers (`sign_in` / `sign_out`) for integration and controller tests.
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
