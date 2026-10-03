require "test_helper"

class ServiceReviewTest < ActiveSupport::TestCase
  test "generates a traceable reference" do
    review = ServiceReview.new(service: services(:health), user: users(:citizen), comment: "Great")
    review.validate
    assert_match(/\AAVIS-\d{4}-[A-Z0-9]{5}\z/, review.reference)
  end

  test "a citizen can only review a service once" do
    duplicate = ServiceReview.new(service: services(:etat_civil), user: users(:admin), comment: "Again")
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "visible excludes hidden reviews" do
    references = ServiceReview.visible.map(&:reference)
    assert_includes references, "AVIS-2026-AAAAA"
    assert_not_includes references, "AVIS-2026-BBBBB"
  end
end
