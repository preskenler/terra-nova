require "test_helper"

class SecurityEventTest < ActiveSupport::TestCase
  test "logs an event" do
    assert_difference -> { SecurityEvent.count }, 1 do
      SecurityEvent.log("sign_in", metadata: { source: "test" })
    end
  end
end
