require "application_system_test_case"

class ServiceAvailabilityTest < ApplicationSystemTestCase
  test "an agent quickly disables a service and the citizen sees the maintenance" do
    visit new_agent_session_path
    fill_in "agent_email", with: agents(:agent).email
    fill_in "agent_password", with: "password123"
    click_button "Connexion"

    click_link "Services", match: :first
    click_button "Désactiver", match: :first
    assert_text "en maintenance"

    visit services_path
    assert_text "En maintenance"
  end

  test "a service under maintenance shows its status before a request" do
    visit service_path(services(:water_maintenance))

    assert_text "Service actuellement en maintenance"
  end
end
