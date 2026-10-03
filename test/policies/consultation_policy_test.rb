require "test_helper"

class ConsultationPolicyTest < ActiveSupport::TestCase
  test "agents can manage consultations" do
    policy = ConsultationPolicy.new(agents(:agent), consultations(:park_opinion))
    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "citizens cannot manage consultations" do
    assert_not ConsultationPolicy.new(users(:citizen), consultations(:park_opinion)).index?
  end
end
