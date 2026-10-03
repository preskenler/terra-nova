require "test_helper"

module Agents
  class AnnouncementsControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot access announcements administration" do
      sign_in users(:citizen)
      get agents_announcements_url
      assert_response :redirect
    end

    test "an agent lists announcements" do
      sign_in agents(:agent)
      get agents_announcements_url
      assert_response :success
      assert_match "Travaux place centrale", response.body
    end

    test "publishing an announcement notifies every citizen" do
      sign_in agents(:agent)

      assert_difference -> { Announcement.count }, 1 do
        assert_difference -> { Notification.count }, User.count do
          post agents_announcements_url, params: {
            announcement: {
              title_fr: "Info", title_en: "Info",
              body_fr: "Contenu", body_en: "Content",
              severity: "info", target_audience: "citizens",
              published_at: Time.current, active: "1"
            }
          }
        end
      end

      assert_redirected_to agents_announcement_path(Announcement.order(:created_at).last)
    end

    test "an agent can delete an announcement" do
      sign_in agents(:agent)

      assert_difference -> { Announcement.count }, -1 do
        delete agents_announcement_url(announcements(:draft))
      end
    end
  end
end
