require "test_helper"

class AssistantControllerTest < ActionDispatch::IntegrationTest
  test "the assistant page renders publicly" do
    get assistant_url

    assert_response :success
    assert_match I18n.t("assistant.label"), response.body
    assert_select "form[action=?]", assistant_path
  end

  test "a query returns suggested services" do
    get assistant_url(q: "acte de naissance")

    assert_response :success
    assert_match I18n.t("assistant.results.heading"), response.body
    assert_match services(:etat_civil).name, response.body
  end

  test "a meaningless query shows the empty state" do
    get assistant_url(q: "zzzzqqqq")

    assert_response :success
    assert_match I18n.t("assistant.results.empty"), response.body
  end
end
