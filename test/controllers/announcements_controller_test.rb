require "test_helper"

class AnnouncementsControllerTest < ActionDispatch::IntegrationTest
  test "index lists published announcements only" do
    get announcements_url
    assert_response :success
    assert_match "Travaux place centrale", response.body
    assert_no_match "Non publié", response.body
  end

  test "show renders a published announcement" do
    get announcement_url(announcements(:info))
    assert_response :success
    assert_match "Travaux place centrale", response.body
  end
end
