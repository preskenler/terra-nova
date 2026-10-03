require "test_helper"

class ProjectPolicyTest < ActiveSupport::TestCase
  test "agents can manage projects" do
    policy = ProjectPolicy.new(agents(:agent), projects(:park))
    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "citizens cannot manage projects" do
    assert_not ProjectPolicy.new(users(:citizen), projects(:park)).index?
  end
end
