require "test_helper"

class ServiceReviewPolicyTest < ActiveSupport::TestCase
  test "agents moderate reviews" do
    policy = ServiceReviewPolicy.new(agents(:agent), service_reviews(:good))
    assert policy.index?
    assert policy.update?
  end

  test "citizens cannot" do
    assert_not ServiceReviewPolicy.new(users(:citizen), service_reviews(:good)).index?
  end
end
