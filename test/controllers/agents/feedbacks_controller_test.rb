require "test_helper"

module Agents
  class FeedbacksControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot access the message queue" do
      sign_in users(:citizen)
      get agents_feedbacks_url
      assert_response :redirect
    end

    test "an agent lists messages" do
      sign_in agents(:agent)
      get agents_feedbacks_url
      assert_response :success
      assert_match "MSG-2026-AAAAA", response.body
    end

    test "updating a message notifies the linked citizen" do
      sign_in agents(:agent)
      feedback = feedbacks(:question)

      assert_difference -> { feedback.user.notifications.count }, 1 do
        patch agents_feedback_url(feedback), params: { feedback: { status: "resolved", agent_notes: "Done" } }
      end

      assert_redirected_to agents_feedback_url(feedback)
      assert_equal "resolved", feedback.reload.status
    end
  end
end
