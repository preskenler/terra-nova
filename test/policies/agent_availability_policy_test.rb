require "test_helper"

class AgentAvailabilityPolicyTest < ActiveSupport::TestCase
  test "agents manage their own availability" do
    policy = AgentAvailabilityPolicy.new(agents(:agent), agent_availabilities(:monday_morning))

    assert policy.index?
    assert policy.new?
    assert policy.create?
    assert policy.destroy?
  end

  test "an agent cannot destroy another agent's availability" do
    other = AgentAvailability.new(agent: agents(:admin), wday: 2, start_time: "08:00", end_time: "09:00", slot_minutes: 30)

    assert_not AgentAvailabilityPolicy.new(agents(:agent), other).destroy?
  end

  test "citizens are denied" do
    assert_not AgentAvailabilityPolicy.new(users(:citizen), agent_availabilities(:monday_morning)).index?
  end

  test "the scope restricts to the agent's own records" do
    scope = AgentAvailabilityPolicy::Scope.new(agents(:agent), AgentAvailability).resolve

    assert_includes scope, agent_availabilities(:monday_morning)
    assert_empty AgentAvailabilityPolicy::Scope.new(users(:citizen), AgentAvailability).resolve
  end
end
