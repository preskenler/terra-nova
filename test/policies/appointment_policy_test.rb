require "test_helper"

class AppointmentPolicyTest < ActiveSupport::TestCase
  test "agents can manage appointments" do
    policy = AppointmentPolicy.new(agents(:agent), appointments(:upcoming))
    assert policy.index?
    assert policy.show?
    assert policy.update?
    assert policy.cancel?
  end

  test "citizens can book and view their own appointments" do
    policy = AppointmentPolicy.new(users(:citizen), appointments(:upcoming))
    assert policy.create?
    assert policy.show?
    assert policy.cancel?
  end

  test "scope restricts citizens to their own appointments" do
    resolved = AppointmentPolicy::Scope.new(users(:citizen), Appointment).resolve
    assert(resolved.all? { |appointment| appointment.user_id == users(:citizen).id })
  end
end
