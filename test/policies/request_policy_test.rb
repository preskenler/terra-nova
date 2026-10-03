require "test_helper"

class RequestPolicyTest < ActiveSupport::TestCase
  test "agents can list and update requests" do
    policy = RequestPolicy.new(agents(:agent), Request)
    assert policy.index?
    assert policy.update?
  end

  test "citizens can create and view their own requests" do
    policy = RequestPolicy.new(users(:citizen), requests(:streetlight))
    assert policy.create?
    assert policy.show?
  end

  test "citizens cannot update requests" do
    assert_not RequestPolicy.new(users(:citizen), requests(:streetlight)).update?
  end

  test "scope restricts citizens to their own requests" do
    resolved = RequestPolicy::Scope.new(users(:citizen), Request).resolve
    assert resolved.any?
    assert(resolved.all? { |request| request.user_id == users(:citizen).id })
  end
end
