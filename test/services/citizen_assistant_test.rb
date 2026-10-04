require "test_helper"

class CitizenAssistantTest < ActiveSupport::TestCase
  test "returns ranked services for a free-text need" do
    result = CitizenAssistant.call("je voudrais un acte de naissance")

    assert_equal "je voudrais un acte de naissance", result[:query]
    assert_includes result[:services].map(&:slug), "etat-civil"
  end

  test "tolerates imperfect wording and still routes to a category" do
    result = CitizenAssistant.call("fuite d eau dans la cave")

    assert_includes result[:services].map(&:slug), "eau"
    assert_equal :report_problem, result[:suggested_step][:type]
  end

  test "routes document requests to the civil registry" do
    result = CitizenAssistant.call("comment obtenir un acte de naissance")

    assert_includes result[:services].map(&:slug), "etat-civil"
    assert_equal :request_document, result[:suggested_step][:type]
  end

  test "returns an empty result for a blank or meaningless query" do
    assert_empty CitizenAssistant.call("").fetch(:services)
    assert_nil CitizenAssistant.call("le la les").fetch(:suggested_step)
  end

  test "is capped at five services" do
    result = CitizenAssistant.call("service aide information ville")

    assert_operator result[:services].size, :<=, 5
  end
end
