require "test_helper"

# Enforces the environmental weight budget of the platform's own assets (F58).
class AssetBudgetTest < ActiveSupport::TestCase
  test "own assets stay within the eco budget" do
    report = Eco::Report.call

    assert_operator report[:css_bytes], :<=, report[:css_budget],
      "CSS budget exceeded (#{report[:css_bytes]} bytes)"
    assert_operator report[:js_bytes], :<=, report[:js_budget],
      "JS budget exceeded (#{report[:js_bytes]} bytes)"
  end
end
