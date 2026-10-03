require "test_helper"

class AgentTest < ActiveSupport::TestCase
  test "defaults to the agent role" do
    assert agents(:agent).agent?
  end

  test "the admin? predicate reflects the role" do
    assert agents(:admin).admin?
    assert_not agents(:agent).admin?
  end

  test "an agent has appointments and availability" do
    assert_respond_to agents(:agent), :appointments
    assert_respond_to agents(:agent), :agent_availabilities
    assert_respond_to agents(:agent), :agent_time_offs
  end
end
