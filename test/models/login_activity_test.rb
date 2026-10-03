require "test_helper"

class LoginActivityTest < ActiveSupport::TestCase
  RequestDouble = Struct.new(:remote_ip, :user_agent)

  setup do
    @user = users(:citizen)
    @user.login_activities.delete_all
  end

  test "the first sign-in is recorded without alerting" do
    assert_no_difference -> { @user.notifications.count } do
      LoginActivity.record!(user: @user, request: RequestDouble.new("1.1.1.1", "Browser A"))
    end
    assert_equal 1, @user.login_activities.count
  end

  test "a new device is reported by notification and email" do
    LoginActivity.record!(user: @user, request: RequestDouble.new("1.1.1.1", "Browser A"))

    assert_difference -> { @user.notifications.count }, 1 do
      assert_enqueued_emails 1 do
        LoginActivity.record!(user: @user, request: RequestDouble.new("2.2.2.2", "Browser B"))
      end
    end
  end

  test "a known device is not reported again" do
    LoginActivity.record!(user: @user, request: RequestDouble.new("1.1.1.1", "Browser A"))

    assert_no_difference -> { @user.notifications.count } do
      LoginActivity.record!(user: @user, request: RequestDouble.new("1.1.1.1", "Browser A"))
    end
  end
end
