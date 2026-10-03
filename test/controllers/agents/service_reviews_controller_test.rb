require "test_helper"

module Agents
  class ServiceReviewsControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot moderate reviews" do
      sign_in users(:citizen)
      get agents_service_reviews_url
      assert_response :redirect
    end

    test "an agent hides a review" do
      sign_in agents(:agent)
      review = service_reviews(:good)

      patch agents_service_review_url(review), params: { service_review: { status: "hidden" } }

      assert_redirected_to agents_service_reviews_url
      assert_equal "hidden", review.reload.status
    end
  end
end
