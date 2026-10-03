require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "generates a unique reference on create" do
    feedback = Feedback.new(subject: "Subject", message: "Message", email: "someone@example.com")
    feedback.validate
    assert_match(/\AMSG-\d{4}-[A-Z0-9]{5}\z/, feedback.reference)
  end

  test "an anonymous message requires an email" do
    feedback = Feedback.new(subject: "Subject", message: "Message")
    assert_not feedback.valid?
    assert feedback.errors[:email].any?
  end

  test "an anonymous message with an email is valid" do
    feedback = Feedback.new(subject: "Subject", message: "Message", email: "someone@example.com")
    assert feedback.valid?
  end

  test "a signed-in citizen does not need an email" do
    feedback = Feedback.new(user: users(:citizen), subject: "Subject", message: "Message")
    assert feedback.valid?
  end
end
