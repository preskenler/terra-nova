require "test_helper"

class TransportsControllerTest < ActionDispatch::IntegrationTest
  test "index lists active lines" do
    get transports_url
    assert_response :success
    assert_match "Tram T1", response.body
    assert_match "Bus B2", response.body
  end

  test "index shows disruptions with a replacement (F97)" do
    line = transport_lines(:bus)
    line.transport_disruptions.create!(
      severity: "critical", message_fr: "Ligne interrompue.",
      replacement_fr: "Empruntez la navette Centre."
    )

    get transports_url

    assert_response :success
    assert_match I18n.t("transports.disruptions.heading"), response.body
    assert_match "Empruntez la navette Centre.", response.body
  end
end
