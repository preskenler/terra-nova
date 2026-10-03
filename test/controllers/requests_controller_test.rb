require "test_helper"

class RequestsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get requests_url
    assert_response :redirect
  end

  test "a citizen lists their requests" do
    sign_in users(:citizen)
    get requests_url
    assert_response :success
    assert_match "NOVA-2026-AAAAA", response.body
  end

  test "creating a request records an event and enqueues a confirmation email" do
    sign_in users(:citizen)

    assert_difference -> { Request.count }, 1 do
      assert_enqueued_emails 1 do
        post requests_url, params: form_protection_params(
          request: { subject: "Graffiti", description: "A wall has been tagged." }
        )
      end
    end

    request = Request.order(:created_at).last
    assert_redirected_to request_url(request)
    assert_equal "submitted", request.status
    assert_equal 1, request.request_events.count
    assert_equal users(:citizen), request.user
  end

  test "an invalid request re-renders the form" do
    sign_in users(:citizen)

    assert_no_difference -> { Request.count } do
      post requests_url, params: form_protection_params(request: { subject: "", description: "" })
    end

    assert_response :unprocessable_content
  end

  test "a citizen cannot open someone else's request" do
    sign_in users(:admin)
    get request_url(requests(:streetlight))
    assert_response :not_found
  end

  test "requests can be downloaded as CSV" do
    sign_in users(:citizen)
    get requests_url(format: :csv)

    assert_response :success
    assert_includes response.media_type, "csv"
    assert_match "NOVA-2026-AAAAA", response.body
  end

  test "a citizen can filter and sort their requests (F79)" do
    sign_in users(:citizen)
    get requests_url(status: "submitted", sort: "oldest")

    assert_response :success
    assert_match "NOVA-2026-AAAAA", response.body
  end

  test "the request form exposes service status before starting (F64)" do
    sign_in users(:citizen)
    get new_request_url

    assert_response :success
    assert_match "data-status", response.body
    assert_match "data-service-status-warning-value", response.body
  end

  test "the new request form is labelled (F42)" do
    sign_in users(:citizen)
    get new_request_url

    assert_select "label[for=?]", "request_subject"
    assert_select "label[for=?]", "request_service_id"
    assert_select "textarea#request_description"
  end

  test "blocks a honeypot submission as a bot (F81)" do
    sign_in users(:citizen)

    assert_no_difference -> { Request.count } do
      assert_difference -> { SecurityEvent.where(event: "form_protection_blocked").count }, 1 do
        post requests_url, params: {
          website: "http://spam.example",
          request: { subject: "Spam", description: "Buy now" }
        }
      end
    end

    assert_response :forbidden
  end

  test "blocks a submission with no form token (F81)" do
    sign_in users(:citizen)

    assert_no_difference -> { Request.count } do
      post requests_url, params: { request: { subject: "No token", description: "x" } }
    end

    assert_response :forbidden
  end

  test "an identical repeat submission is not duplicated (F82)" do
    sign_in users(:citizen)
    params = form_protection_params(
      request: { subject: "Pothole", description: "A large pothole on Main street." }
    )

    assert_difference -> { Request.count }, 1 do
      post requests_url, params: params
    end
    existing = Request.order(:created_at).last

    assert_no_difference -> { Request.count } do
      post requests_url, params: params
    end

    assert_redirected_to request_url(existing)
    assert_match existing.reference, flash[:notice].to_s
  end

  test "the request page shows an acknowledgement with the reference (F83)" do
    sign_in users(:citizen)
    request = requests(:streetlight)

    get request_url(request)

    assert_response :success
    assert_match I18n.t("requests.acknowledgement.title"), response.body
    assert_match request.reference, response.body
  end
end
