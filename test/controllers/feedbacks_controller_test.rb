require "test_helper"

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "the contact form is public" do
    get new_feedback_url
    assert_response :success
  end

  test "the contact form is labelled for assistive technologies (F21/F42)" do
    get new_feedback_url
    assert_select "label[for=?]", "feedback_subject"
    assert_select "label[for=?]", "feedback_message"
    assert_select "form select#feedback_kind"
  end

  test "an anonymous message without an email is rejected" do
    assert_no_difference -> { Feedback.count } do
      post feedback_url, params: form_protection_params(
        feedback: { kind: "question", subject: "Hi", message: "Hello" }
      )
    end

    assert_response :unprocessable_content
  end

  test "an anonymous message with an email is accepted" do
    assert_difference -> { Feedback.count }, 1 do
      post feedback_url, params: form_protection_params(
        feedback: { kind: "data_concern", subject: "Data", message: "How is it used?", email: "visitor@example.com" }
      )
    end

    assert_redirected_to root_url
  end

  test "a signed-in citizen's message is linked to their account" do
    sign_in users(:citizen)

    assert_difference -> { users(:citizen).feedbacks.count }, 1 do
      post feedback_url, params: form_protection_params(
        feedback: { kind: "suggestion", subject: "Idea", message: "A suggestion." }
      )
    end
  end

  test "blocks a bot submission (F81)" do
    assert_no_difference -> { Feedback.count } do
      post feedback_url, params: {
        website: "bot",
        feedback: { kind: "question", subject: "Hi", message: "x", email: "a@b.c" }
      }
    end

    assert_response :forbidden
  end
end
