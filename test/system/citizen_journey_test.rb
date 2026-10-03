require "application_system_test_case"

class CitizenJourneyTest < ApplicationSystemTestCase
  test "a citizen signs in and creates a request end to end" do
    visit new_user_session_path
    fill_in "user_email", with: users(:citizen).email
    fill_in "user_password", with: "password123"
    click_button "Connexion"

    assert_current_path "/espace"
    assert_text "Mon espace"

    visit new_request_path
    fill_in "request_subject", with: "Lampadaire cassé"
    fill_in "request_description", with: "Le lampadaire devant le 12 est cassé."
    click_button "Envoyer ma demande"

    assert_text "a bien été envoyée"
    assert_text "Lampadaire cassé"
  end
end
