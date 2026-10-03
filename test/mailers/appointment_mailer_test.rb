require "test_helper"

class AppointmentMailerTest < ActionMailer::TestCase
  test "confirmation email is addressed to the citizen" do
    email = AppointmentMailer.confirmation(appointments(:upcoming))

    assert_equal [ users(:citizen).email ], email.to
    assert_match(/\w/, email.subject)
  end

  test "reminder email is addressed to the citizen" do
    email = AppointmentMailer.reminder(appointments(:upcoming))

    assert_equal [ users(:citizen).email ], email.to
  end
end
