require "test_helper"

class PartnerPolicyTest < ActiveSupport::TestCase
  test "agents manage partners" do
    policy = PartnerPolicy.new(agents(:agent), partners(:health))
    assert policy.index?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "citizens cannot" do
    assert_not PartnerPolicy.new(users(:citizen), partners(:health)).index?
  end
end
