require "test_helper"

# Enforces the environmental weight budget of the platform's own assets (F58).
# Measured on the gzipped (transferred) size so it is stable across environments.
class AssetBudgetTest < ActiveSupport::TestCase
  test "own assets stay within the eco budget" do
    report = Eco::Report.call

    assert_operator report[:css_gzip_bytes], :<=, report[:css_budget],
      "CSS budget exceeded (#{report[:css_gzip_bytes]} bytes gzipped)"
    assert_operator report[:js_gzip_bytes], :<=, report[:js_budget],
      "JS budget exceeded (#{report[:js_gzip_bytes]} bytes gzipped)"
  end
end
