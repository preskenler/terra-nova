require "application_system_test_case"

class ParticipationTest < ApplicationSystemTestCase
  test "a citizen responds to a consultation and proposes an idea" do
    visit new_user_session_path
    fill_in "user_email", with: users(:citizen).email
    fill_in "user_password", with: "password123"
    click_button "Connexion"

    visit consultation_path(consultations(:park_opinion))
    choose "choice_favorable"
    click_button "Envoyer mon avis"
    assert_text "votre avis a bien été enregistré"

    visit new_idea_path
    fill_in "idea_title", with: "More trees"
    fill_in "idea_description", with: "Plant more trees downtown."
    click_button "Envoyer mon idée"
    assert_text "a bien été enregistrée"
  end
end
