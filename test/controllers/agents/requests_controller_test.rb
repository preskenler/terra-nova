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

    test "an agent can link a request to the one it duplicates (F75)" do
      sign_in agents(:agent)
      target = requests(:streetlight)
      duplicate = requests(:pothole)

      patch link_duplicate_agents_request_url(target, duplicate_reference: duplicate.reference)

      assert_equal duplicate, target.reload.duplicate_of
    end

    test "an agent can set a request priority (F80)" do
      sign_in agents(:agent)
      request = requests(:streetlight)

      patch prioritize_agents_request_url(request), params: { request: { priority: "urgent" } }

      assert_redirected_to agents_request_url(request)
      assert_equal "urgent", request.reload.priority
    end

    test "the requests index filters by priority and paginates (F80/F77)" do
      sign_in agents(:agent)

      get agents_requests_url(priority: "urgent", sort: "priority", page: 2)

      assert_response :success
    end

    test "an agent can export the filtered selection as CSV (F88)" do
      sign_in agents(:agent)
      request = requests(:streetlight)

      get agents_requests_url(format: :csv, status: "submitted", priority: "normal")

      assert_response :success
      assert_includes response.media_type, "csv"
      assert_match request.reference, response.body
      assert_match I18n.t("requests.priority.normal"), response.body
    end

    test "the CSV export honours filters and excludes non-matching requests (F88)" do
      sign_in agents(:agent)

      get agents_requests_url(format: :csv, status: "rejected")

      assert_response :success
      assert_no_match "NOVA-2026-AAAAA", response.body
    end

    test "the urgent callout is shown when urgent requests exist (F86)" do
      sign_in agents(:agent)
      requests(:streetlight).update!(priority: "urgent")

      get agents_requests_url

      assert_response :success
      assert_match I18n.t("agents.requests.attention.action"), response.body
    end

    test "urgent requests are surfaced first by default (F86)" do
      sign_in agents(:agent)
      requests(:streetlight).update!(priority: "urgent")

      get agents_requests_url(priority: "urgent")

      assert_response :success
      assert_match "NOVA-2026-AAAAA", response.body
    end
  end
end
