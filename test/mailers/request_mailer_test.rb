require "test_helper"

class RequestMailerTest < ActionMailer::TestCase
  test "submitted email is addressed to the citizen" do
    email = RequestMailer.submitted(requests(:streetlight))

    assert_equal [ users(:citizen).email ], email.to
    assert_match "NOVA-2026-AAAAA", email.subject
  end

  test "status changed email is addressed to the citizen" do
    email = RequestMailer.status_changed(requests(:streetlight), request_events(:submitted_event))

    assert_equal [ users(:citizen).email ], email.to
    assert_match "NOVA-2026-AAAAA", email.subject
  end
end
