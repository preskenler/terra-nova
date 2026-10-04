require "test_helper"

class ApplicationPolicyTest < ActiveSupport::TestCase
  test "the base policy denies everything by default" do
    policy = ApplicationPolicy.new(users(:citizen), Object.new)

    assert_not policy.index?
    assert_not policy.show?
    assert_not policy.create?
    assert_not policy.new?
    assert_not policy.update?
    assert_not policy.edit?
    assert_not policy.destroy?
  end

  test "the base scope must define resolve" do
    scope = ApplicationPolicy::Scope.new(users(:citizen), User)

    assert_raises(NoMethodError) { scope.resolve }
  end
end
