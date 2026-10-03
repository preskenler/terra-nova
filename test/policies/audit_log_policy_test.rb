require "test_helper"

class AuditLogPolicyTest < ActiveSupport::TestCase
  test "agents can read the audit log" do
    policy = AuditLogPolicy.new(agents(:agent), :audit_log)
    assert policy.index?
    assert policy.show?
  end

  test "citizens cannot read the audit log" do
    assert_not AuditLogPolicy.new(users(:citizen), :audit_log).index?
  end
end
