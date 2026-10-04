require "test_helper"

module Agents
  class ExportsControllerTest < ActionDispatch::IntegrationTest
    test "requires an authenticated agent" do
      get agents_exports_requests_url
      assert_response :redirect
    end

    test "regular agents cannot download the data backup" do
      sign_in agents(:agent)
      get agents_exports_requests_url
      assert_response :redirect
    end

    test "administrators can download a clear, reusable backup (F87)" do
      sign_in agents(:admin)

      get agents_exports_requests_url

      assert_response :success
      assert_includes response.media_type, "csv"
      assert_match I18n.t("agents.exports.requests.title"), response.body
      assert_match I18n.t("agents.exports.requests.total"), response.body
      assert_match "NOVA-2026-AAAAA", response.body
    end
  end
end
