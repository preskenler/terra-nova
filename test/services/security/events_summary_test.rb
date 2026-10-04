require "test_helper"

module Security
  class EventsSummaryTest < ActiveSupport::TestCase
    test "reports a normal state when activity is low" do
      summary = Security::EventsSummary.new(period: 1.hour).call

      assert_equal false, summary[:suspicious]
      assert_empty summary[:signals]
    end

    test "flags an unusual volume of blocked automated submissions (F85)" do
      6.times do
        SecurityEvent.create!(event: "form_protection_blocked", ip: "203.0.113.7")
      end

      summary = Security::EventsSummary.new(period: 1.hour).call

      assert summary[:suspicious]
      assert_equal 6, summary[:signals]["form_protection_blocked"]
      assert_equal "203.0.113.7", summary[:top_ips].keys.first
    end

    test "does not flag a handful of isolated failures" do
      2.times { SecurityEvent.create!(event: "sign_in_failed", ip: "198.51.100.9") }

      assert_not Security::EventsSummary.new(period: 1.hour).suspicious?
    end
  end
end
