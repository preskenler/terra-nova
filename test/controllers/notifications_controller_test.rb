require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get notifications_url
    assert_response :redirect
  end

  test "lists the citizen notifications" do
    sign_in users(:citizen)
    get notifications_url
    assert_response :success
    assert_match "Welcome", response.body
  end

  test "marks a notification as read" do
    sign_in users(:citizen)
    notification = notifications(:status_update)
    assert_not notification.read?

    patch notification_url(notification)

    assert_redirected_to notifications_url
    assert notification.reload.read?
  end
end
