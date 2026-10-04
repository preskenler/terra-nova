require "test_helper"

class Services::UsageTest < ActiveSupport::TestCase
  test "ranks services by combined usage" do
    service = services(:etat_civil)
    user = users(:citizen)
    # Add usage so etat_civil clearly leads.
    3.times do |i|
      Request.create!(user: user, service: service, subject: "Usage #{i}", description: "x")
    end

    result = Services::Usage.call

    assert result[:rows].any?
    assert_equal "etat-civil", result[:rows].first.service.slug
    assert_operator result[:rows].first.total, :>=, 3
    assert_operator result[:max_total], :>=, result[:rows].first.total
  end

  test "returns a summary with a top service and a total" do
    result = Services::Usage.call

    assert result.key?(:top)
    assert result.key?(:total_requests)
    assert_operator result[:rows].size, :<=, 10
  end
end
