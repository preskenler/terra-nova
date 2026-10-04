require "test_helper"

module Agents
  class ConsultationsControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot manage consultations" do
      sign_in users(:citizen)
      get agents_consultations_url
      assert_response :redirect
    end

    test "an agent creates a consultation" do
      sign_in agents(:agent)

      assert_difference -> { Consultation.count }, 1 do
        post agents_consultations_url, params: {
          consultation: { title_fr: "Nouvelle", title_en: "New", kind: "opinion", status: "open" }
        }
      end

      assert_redirected_to agents_consultation_url(Consultation.order(:created_at).last)
    end

    test "an agent sees the results of a consultation" do
      sign_in agents(:agent)
      get agents_consultation_url(consultations(:park_opinion))

      assert_response :success
      assert_match "Favorable", response.body
    end

    test "an agent views, updates and deletes a consultation" do
      sign_in agents(:agent)
      consultation = consultations(:park_opinion)

      get agents_consultation_url(consultation)
      assert_response :success

      get edit_agents_consultation_url(consultation)
      assert_response :success

      patch agents_consultation_url(consultation), params: { consultation: { status: "closed" } }
      assert_redirected_to agents_consultation_url(consultation)
      assert_equal "closed", consultation.reload.status

      assert_difference -> { Consultation.count }, -1 do
        delete agents_consultation_url(consultation)
      end
    end

    test "an invalid consultation re-renders the form" do
      sign_in agents(:agent)

      assert_no_difference -> { Consultation.count } do
        post agents_consultations_url, params: { consultation: { title_fr: "" } }
      end
      assert_response :unprocessable_content
    end
  end
end
