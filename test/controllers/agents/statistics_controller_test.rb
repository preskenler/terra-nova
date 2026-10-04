require "test_helper"

module Agents
  class StatisticsControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot view usage statistics" do
      sign_in users(:citizen)
      get agents_statistics_url
      assert_response :redirect
    end

    test "an agent sees the most-used services (F98)" do
      sign_in agents(:agent)
      request = requests(:streetlight)
      request.update!(service: services(:etat_civil))

      get agents_statistics_url

      assert_response :success
      assert_select "h1", text: I18n.t("agents.statistics.title")
      assert_match "État civil", response.body
    end
  end
end
