require "test_helper"

# Renders every key page to catch template parse/render errors (e.g. malformed
# ERB) that focused tests might miss.
class PagesSmokeTest < ActionDispatch::IntegrationTest
  PUBLIC_PAGES = %w[
    / /services /services/etat-civil /transports /glossary /announcements
    /alerts /projects /projects/reamenagement-du-parc-central /ideas
    /feedback/new /transparency /accessibility /eco /users/magic_link
    /users/sign_in /users/sign_up
  ].freeze

  CITIZEN_PAGES = %w[
    /espace /onboarding /profile /profile/edit /account /account/data
    /requests /requests/new /appointments /appointments/new /notifications
    /profile/two_factor
  ].freeze

  AGENT_PAGES = %w[
    /agents /agents/requests /agents/users /agents/services /agents/announcements
    /agents/alerts /agents/projects /agents/consultations /agents/ideas
    /agents/feedbacks /agents/audit_logs /agents/appointments /agents/demands
    /agents/availabilities
  ].freeze

  test "public pages render" do
    PUBLIC_PAGES.each do |path|
      get path
      assert_response :success, "#{path} did not render (status #{response.status})"
    end
  end

  test "citizen pages render" do
    sign_in users(:citizen)
    CITIZEN_PAGES.each do |path|
      get path
      assert_response :success, "#{path} did not render (status #{response.status})"
    end
  end

  test "agent pages render" do
    sign_in agents(:agent)
    AGENT_PAGES.each do |path|
      get path
      assert_response :success, "#{path} did not render (status #{response.status})"
    end
  end
end
