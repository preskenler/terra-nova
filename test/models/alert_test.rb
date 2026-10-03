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

  test "an alert can target a specific segment (F31)" do
    alert = Alert.new(target_segment: "vulnerable")
    assert alert.vulnerable?
    assert_equal "vulnerable", alert.target_segment
  end
end
