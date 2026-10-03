require "test_helper"

module Agents
  class RequestsControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot access the agent request list" do
      sign_in users(:citizen)
      get agents_requests_url
      assert_response :redirect
    end

    test "an agent lists citizen requests" do
      sign_in agents(:agent)
      get agents_requests_url
      assert_response :success
      assert_match "NOVA-2026-AAAAA", response.body
    end

    test "updating the status records an event, notifies and emails the citizen" do
      sign_in agents(:agent)
      request = requests(:streetlight)

      assert_difference -> { request.request_events.count }, 1 do
        assert_enqueued_emails 1 do
          patch agents_request_url(request), params: {
            request_event: { to_status: "in_progress", comment: "A team is on the way.", visible_to_citizen: "1" }
          }
        end
      end

      assert_redirected_to agents_request_url(request)
      assert_equal "in_progress", request.reload.status
      assert request.user.notifications.where(kind: "status_change").exists?
    end

    test "an internal-only update does not notify the citizen" do
      sign_in agents(:agent)
      request = requests(:pothole)

      assert_no_difference -> { request.user.notifications.count } do
        patch agents_request_url(request), params: {
          request_event: { to_status: "closed", comment: "Internal note.", visible_to_citizen: "0" }
        }
      end
    end
  end
end
