require "test_helper"

class AuditLogPolicyTest < ActiveSupport::TestCase
  test "administrators can read the audit log" do
    policy = AuditLogPolicy.new(agents(:admin), :audit_log)
    assert policy.index?
    assert policy.show?
  end

  test "regular agents cannot read the audit log" do
    assert_not AuditLogPolicy.new(agents(:agent), :audit_log).index?
  end

  test "citizens cannot read the audit log" do
    assert_not AuditLogPolicy.new(users(:citizen), :audit_log).index?
  end
end
