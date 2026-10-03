require "test_helper"

class DemandTest < ActiveSupport::TestCase
  test "requires a request code and a public message" do
    demand = Demand.new
    assert_not demand.valid?
    assert demand.errors[:request_code].any?
    assert demand.errors[:message_public].any?
  end

  test "request_code is unique" do
    duplicate = Demand.new(request_code: demands(:d01).request_code,
                           message_public: "Duplicate")
    assert_not duplicate.valid?
    assert duplicate.errors[:request_code].any?
  end

  test "difficulty_label falls back to the numeric level" do
    assert_equal "Facile", demands(:d01).difficulty_label
    assert_equal "Moyenne", demands(:f52).difficulty_label
  end

  test "xp prefers the available amount" do
    assert_equal 250, demands(:d01).xp
    assert_equal 660, demands(:f52).xp
  end

  test "new_arrivals scope only returns unseen demands" do
    codes = Demand.new_arrivals.map(&:request_code)
    assert_includes codes, "D01"
    assert_not_includes codes, "F52"
  end
end
