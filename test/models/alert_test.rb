require "test_helper"

class AlertTest < ActiveSupport::TestCase
  test "active_now excludes ended alerts" do
    ids = Alert.active_now.map(&:id)
    assert_includes ids, alerts(:flood).id
    assert_not_includes ids, alerts(:expired).id
  end

  test "critical? predicate" do
    assert alerts(:flood).critical?
    assert_not alerts(:expired).critical?
  end
end
