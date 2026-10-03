require "test_helper"

# Full-stack browser-style tests. The RackTest driver runs everywhere (including
# CI without a browser) and exercises the real request/response cycle.
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :rack_test
end
