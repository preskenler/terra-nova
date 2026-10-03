require "test_helper"

class ConsultationResponsesControllerTest < ActionDispatch::IntegrationTest
  test "a citizen can respond to an open consultation" do
    sign_in users(:citizen)
    consultation = consultations(:park_opinion)

    assert_difference -> { ConsultationResponse.count }, 1 do
      assert_difference -> { users(:citizen).notifications.count }, 1 do
        post consultation_response_url(consultation),
             params: { consultation_response: { choice: "favorable", comment: "Good idea" } }
      end
    end

    assert_redirected_to consultation_url(consultation)
  end

  test "a closed consultation cannot be answered" do
    sign_in users(:citizen)
    consultation = consultations(:closed_survey)

    assert_no_difference -> { ConsultationResponse.count } do
      post consultation_response_url(consultation), params: { consultation_response: { choice: "favorable" } }
    end

    assert_redirected_to consultation_url(consultation)
  end
end
