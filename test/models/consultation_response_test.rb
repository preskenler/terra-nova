require "test_helper"

class ConsultationResponseTest < ActiveSupport::TestCase
  test "generates a traceable reference" do
    response = ConsultationResponse.new(
      consultation: consultations(:park_opinion), user: users(:citizen), choice: "favorable"
    )
    response.validate
    assert_match(/\APART-\d{4}-[A-Z0-9]{5}\z/, response.reference)
  end

  test "a citizen can only answer a consultation once" do
    duplicate = ConsultationResponse.new(
      consultation: consultations(:park_opinion), user: users(:admin), choice: "unfavorable"
    )
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end
end
