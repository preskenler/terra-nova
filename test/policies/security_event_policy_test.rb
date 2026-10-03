require "test_helper"

class SecurityEventPolicyTest < ActiveSupport::TestCase
  test "administrators can read security events" do
    assert SecurityEventPolicy.new(agents(:admin), :security_event).index?
  end

  test "regular agents cannot" do
    assert_not SecurityEventPolicy.new(agents(:agent), :security_event).index?
  end

  test "citizens cannot" do
    assert_not SecurityEventPolicy.new(users(:citizen), :security_event).index?
  end
end
