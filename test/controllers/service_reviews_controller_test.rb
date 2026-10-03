require "test_helper"

class ServiceReviewsControllerTest < ActionDispatch::IntegrationTest
  test "a signed-in citizen can review a service" do
    sign_in users(:citizen)
    service = services(:health)

    assert_difference -> { ServiceReview.count }, 1 do
      assert_difference -> { users(:citizen).notifications.count }, 1 do
        post service_review_url(service), params: { service_review: { rating: "5", comment: "Excellent" } }
      end
    end

    assert_redirected_to service_url(service)
  end

  test "an anonymous visitor cannot review" do
    post service_review_url(services(:health)), params: { service_review: { comment: "Hi" } }
    assert_response :redirect
  end
end
