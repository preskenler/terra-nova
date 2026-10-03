require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "magic link email is addressed to the citizen" do
    email = UserMailer.magic_link(users(:citizen), "https://example.com/users/magic_link/abc")
    assert_equal [ users(:citizen).email ], email.to
  end

  test "new sign-in email is addressed to the citizen" do
    email = UserMailer.new_sign_in(users(:citizen), ip: "1.2.3.4", user_agent: "Browser")
    assert_equal [ users(:citizen).email ], email.to
  end
end
