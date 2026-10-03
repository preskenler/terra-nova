require "test_helper"

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "the contact form is public" do
    get new_feedback_url
    assert_response :success
  end

  test "an anonymous message without an email is rejected" do
    assert_no_difference -> { Feedback.count } do
      post feedback_url, params: { feedback: { kind: "question", subject: "Hi", message: "Hello" } }
    end

    assert_response :unprocessable_content
  end

  test "an anonymous message with an email is accepted" do
    assert_difference -> { Feedback.count }, 1 do
      post feedback_url, params: {
        feedback: { kind: "data_concern", subject: "Data", message: "How is it used?", email: "visitor@example.com" }
      }
    end

    assert_redirected_to root_url
  end

  test "a signed-in citizen's message is linked to their account" do
    sign_in users(:citizen)

    assert_difference -> { users(:citizen).feedbacks.count }, 1 do
      post feedback_url, params: { feedback: { kind: "suggestion", subject: "Idea", message: "A suggestion." } }
    end
  end
end
