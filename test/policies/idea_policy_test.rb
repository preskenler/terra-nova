require "test_helper"

class IdeaPolicyTest < ActiveSupport::TestCase
  test "agents can moderate ideas" do
    policy = IdeaPolicy.new(agents(:agent), ideas(:compost))
    assert policy.index?
    assert policy.show?
    assert policy.update?
  end

  test "citizens cannot moderate ideas" do
    assert_not IdeaPolicy.new(users(:citizen), ideas(:compost)).index?
  end
end
