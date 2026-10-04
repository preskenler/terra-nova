require "test_helper"

module Agents
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot access the agent dashboard" do
      sign_in users(:citizen)
      get agents_root_url
      assert_response :redirect
    end

    test "an agent sees platform and API activity (F50)" do
      sign_in agents(:agent)

      get agents_root_url

      assert_response :success
      assert_select "h2", text: "Activité de la plateforme"
      assert_select "h2", text: "Flux de l'API Terra Nova"
    end

    test "the agent header uses the grouped megamenu" do
      sign_in agents(:agent)

      get agents_root_url

      assert_select "div.megamenu#agents-menu"
      assert_select "div#agents-menu button[popovertarget=?]", "agents-menu-citizens"
      assert_select "div#agents-menu-citizens li a", text: I18n.t("agents.nav.requests")
      # Administration group is hidden from non-administrator agents.
      assert_select "button[popovertarget=?]", "agents-menu-administration", count: 0
    end

    test "administrators also see the administration group" do
      sign_in agents(:admin)

      get agents_root_url

      assert_select "button[popovertarget=?]", "agents-menu-administration"
    end

    test "the dashboard shows the latest security events (F100)" do
      SecurityEvent.create!(event: "sign_in_failed", ip: "203.0.113.9")
      sign_in agents(:agent)

      get agents_root_url

      assert_response :success
      assert_match I18n.t("agents.dashboard.security"), response.body
      assert_match I18n.t("agents.security_events.events.sign_in_failed"), response.body
    end
  end
end
