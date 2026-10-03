require "test_helper"

class DemandPolicyTest < ActiveSupport::TestCase
  test "an agent can list and edit demands" do
    policy = DemandPolicy.new(agents(:agent), Demand)
    assert policy.index?
    assert policy.show?
    assert policy.update?
    assert policy.refresh?
  end

  test "a citizen cannot access demands" do
    policy = DemandPolicy.new(users(:citizen), Demand)
    assert_not policy.index?
    assert_not policy.update?
  end
end
