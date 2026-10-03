require "test_helper"

module Agents
  # Agent replies to requests (F84).
  class RequestRepliesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @citizen_request = requests(:streetlight)
    end

    test "an agent replies publicly and the citizen is notified (F84)" do
      sign_in agents(:admin)

      assert_difference -> { RequestReply.count }, 1 do
        assert_difference -> { @citizen_request.user.notifications.count }, 1 do
          assert_enqueued_emails 1 do
            post agents_request_replies_url(@citizen_request),
                 params: { request_reply: { body: "We are on it." } }
          end
        end
      end

      reply = RequestReply.order(:created_at).last
      assert_equal "Agent", reply.created_by_type
      assert_not reply.internal?
      assert_redirected_to agents_request_url(@citizen_request)
    end

    test "an internal reply does not notify the citizen (F84)" do
      sign_in agents(:admin)

      assert_difference -> { RequestReply.count }, 1 do
        assert_no_difference -> { @citizen_request.user.notifications.count } do
          assert_no_enqueued_emails do
            post agents_request_replies_url(@citizen_request),
                 params: { request_reply: { body: "Internal note", internal: "1" } }
          end
        end
      end

      assert RequestReply.order(:created_at).last.internal?
    end

    test "a citizen cannot post an agent reply" do
      sign_in users(:citizen)

      assert_no_difference -> { RequestReply.count } do
        post agents_request_replies_url(@citizen_request), params: { request_reply: { body: "nope" } }
      end

      assert_response :redirect
    end

    test "public replies are visible to the owner on the request page (F84)" do
      sign_in agents(:admin)
      post agents_request_replies_url(@citizen_request),
           params: { request_reply: { body: "Public answer here" } }

      sign_out agents(:admin)
      sign_in users(:citizen)
      get request_url(@citizen_request)

      assert_response :success
      assert_match "Public answer here", response.body
    end
  end
end
