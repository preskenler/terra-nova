require "test_helper"

class AgentTimeOffPolicyTest < ActiveSupport::TestCase
  test "agents manage their own time off" do
    policy = AgentTimeOffPolicy.new(agents(:agent), agent_time_offs(:conference))

    assert policy.index?
    assert policy.new?
    assert policy.create?
    assert policy.destroy?
  end

  test "an agent cannot destroy another agent's time off" do
    other = AgentTimeOff.new(agent: agents(:admin), starts_at: 1.day.from_now, ends_at: 2.days.from_now)

    assert_not AgentTimeOffPolicy.new(agents(:agent), other).destroy?
  end

  test "citizens are denied" do
    assert_not AgentTimeOffPolicy.new(users(:citizen), agent_time_offs(:conference)).index?
  end

  test "the scope restricts to the agent's own records" do
    scope = AgentTimeOffPolicy::Scope.new(agents(:agent), AgentTimeOff).resolve

    assert_includes scope, agent_time_offs(:conference)
    assert_empty AgentTimeOffPolicy::Scope.new(users(:citizen), AgentTimeOff).resolve
  end
end
