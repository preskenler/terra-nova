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

  test "a pinned announcement appears on every page (F73)" do
    announcements(:info).update!(pinned: true)
    get glossary_url
    assert_response :success
    assert_match announcements(:info).title, response.body
  end
end
