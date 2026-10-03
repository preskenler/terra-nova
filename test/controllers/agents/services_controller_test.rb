require "test_helper"

module Agents
  class ServicesControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot manage services" do
      sign_in users(:citizen)
      get agents_services_url
      assert_response :redirect
    end

    test "an agent lists the service catalog" do
      sign_in agents(:agent)
      get agents_services_url
      assert_response :success
      assert_match "etat-civil", response.body
    end

    test "an agent can quickly disable and re-enable a service (F63)" do
      sign_in agents(:agent)
      service = services(:etat_civil)
      assert service.active?

      patch disable_agents_service_url(service)
      assert_redirected_to agents_services_url
      assert_equal "maintenance", service.reload.status

      patch enable_agents_service_url(service)
      assert_equal "active", service.reload.status
    end

    test "an agent can update the maintenance message" do
      sign_in agents(:agent)
      service = services(:water_maintenance)

      patch agents_service_url(service), params: {
        service: { status: "maintenance", maintenance_message_fr: "Panne en cours", expected_return: "Demain" }
      }

      assert_redirected_to agents_services_url
      assert_equal "Panne en cours", service.reload.maintenance_message_fr
    end
  end
end
