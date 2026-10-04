ENV["RAILS_ENV"] ||= "test"

# Measure coverage before the application is loaded. Enabled in CI or when
# COVERAGE=1, so the local suite stays fast by default.
if ENV["CI"] || ENV["COVERAGE"] == "1"
  require "simplecov"
  require "simplecov-cobertura"

  SimpleCov.start "rails" do
    enable_coverage :branch
    # The report is uploaded to Codecov, which tracks the percentage over time.
    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::CoberturaFormatter,
      SimpleCov::Formatter::HTMLFormatter
    ])
    add_filter %r{^/test/}
  end
end

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in a single process by default for deterministic output. The
    # MySQL role may create per-worker databases; override with
    # PARALLEL_WORKERS to run the suite in parallel.
    parallelize(workers: Integer(ENV.fetch("PARALLEL_WORKERS", 1)))

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Helpers for testing mailers and background jobs.
    include ActiveJob::TestHelper
    include ActionMailer::TestHelper

    # Builds form params with a valid anti-automation token and a blank honeypot
    # (F81), so tests exercise the protected path.
    def form_protection_params(params = {})
      token = FormProtection.verifier.generate(2.minutes.ago.to_i)
      { form_token: token, website: "" }.merge(params)
    end
  end
end

# Devise helpers (`sign_in` / `sign_out`) for integration and controller tests.
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

# Date helpers for appointment tests.
module AppointmentTestDates
  # Returns a Monday at least one day in the future.
  def next_monday
    date = Date.current + 7.days
    date -= 1.day until date.wday == 1
    date
  end
end

ActiveSupport::TestCase.include AppointmentTestDates
ActionDispatch::IntegrationTest.include AppointmentTestDates
