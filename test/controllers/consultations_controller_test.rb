require "test_helper"

class ConsultationsControllerTest < ActionDispatch::IntegrationTest
  test "show renders an open consultation with the participation section" do
    get consultation_url(consultations(:park_opinion))
    assert_response :success
    assert_match "Aire de jeux", response.body
    assert_match "Participer", response.body
  end

  test "a citizen who already answered sees the recorded reference" do
    sign_in users(:admin)
    get consultation_url(consultations(:park_opinion))
    assert_match "PART-2026-AAAAA", response.body
  end
end
