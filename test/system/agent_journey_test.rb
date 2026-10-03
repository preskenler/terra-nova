require "application_system_test_case"

class AgentJourneyTest < ApplicationSystemTestCase
  test "an agent updates a request status and the citizen is notified" do
    request = requests(:streetlight)

    visit new_agent_session_path
    fill_in "agent_email", with: agents(:agent).email
    fill_in "agent_password", with: "password123"
    click_button "Connexion"
    assert_current_path "/agents"

    # Navigate through the workspace like a real agent.
    click_link "Demandes citoyennes", match: :first
    click_link request.reference, match: :first

    select "En cours de traitement", from: "request_event_to_status"
    fill_in "request_event_comment", with: "Une équipe est sur place."
    check "request_event_visible_to_citizen"
    click_button "Enregistrer"

    assert_text "mise à jour"
    assert_equal "in_progress", request.reload.status
    assert request.user.notifications.where(kind: "status_change").exists?
  end
end
