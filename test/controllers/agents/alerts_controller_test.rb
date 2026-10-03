require "test_helper"

module Agents
  class AlertsControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot access alerts administration" do
      sign_in users(:citizen)
      get agents_alerts_url
      assert_response :redirect
    end

    test "an agent lists alerts" do
      sign_in agents(:agent)
      get agents_alerts_url
      assert_response :success
      assert_match "Montée des eaux", response.body
    end

    test "broadcasting an alert notifies citizens" do
      sign_in agents(:agent)

      assert_difference -> { Alert.count }, 1 do
        assert_difference -> { Notification.count }, User.count do
          post agents_alerts_url, params: {
            alert: {
              title_fr: "Alerte", title_en: "Alert",
              body_fr: "Contenu", body_en: "Content",
              kind: "flood", severity: "critical", target_segment: "all",
              locality: "Quartier sud", starts_at: Time.current, active: "1"
            }
          }
        end
      end

      assert_redirected_to agents_alert_path(Alert.order(:created_at).last)
    end
  end
end
