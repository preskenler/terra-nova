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
  end
end
