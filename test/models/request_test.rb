require "test_helper"

class RequestTest < ActiveSupport::TestCase
  test "generates a unique reference on create" do
    request = Request.new(user: users(:citizen), subject: "Subject", description: "Description")
    request.validate
    assert_match(/\ANOVA-\d{4}-[A-Z0-9]{5}\z/, request.reference)
  end

  test "requires a subject and a description" do
    request = Request.new(user: users(:citizen))
    assert_not request.valid?
    assert request.errors[:subject].any?
    assert request.errors[:description].any?
  end

  test "support tracking" do
    request = requests(:streetlight)
    assert request.supported_by?(users(:admin))
    assert_not request.supported_by?(users(:citizen))
    assert_equal 1, request.support_count
  end

  test "open_requests only returns actionable requests" do
    references = Request.open_requests.map(&:reference)
    assert_includes references, "NOVA-2026-AAAAA"
    assert_not_includes references, "NOVA-2026-BBBBB"
  end

  test "created_by is polymorphic on events" do
    event = request_events(:submitted_event)
    assert_nil event.created_by
    assert_equal "submitted", event.to_status
  end
end
