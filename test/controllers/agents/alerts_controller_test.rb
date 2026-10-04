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

    test "an invalid alert re-renders the form" do
      sign_in agents(:agent)

      assert_no_difference -> { Alert.count } do
        post agents_alerts_url, params: { alert: { title_fr: "", kind: "flood", severity: "critical" } }
      end
      assert_response :unprocessable_content
    end

    test "an inactive alert does not notify citizens" do
      sign_in agents(:agent)

      assert_difference -> { Alert.count }, 1 do
        assert_no_difference -> { Notification.count } do
          post agents_alerts_url, params: {
            alert: { title_fr: "Info", title_en: "Info", body_fr: "x", body_en: "x",
                     kind: "flood", severity: "info", target_segment: "all", active: "0" }
          }
        end
      end
    end

    test "an agent updates and deletes an alert" do
      sign_in agents(:agent)
      alert = alerts(:flood)

      get edit_agents_alert_url(alert)
      assert_response :success

      patch agents_alert_url(alert), params: { alert: { severity: "info" } }
      assert_redirected_to agents_alert_path(alert)

      assert_difference -> { Alert.count }, -1 do
        delete agents_alert_url(alert)
      end
    end
  end
end
