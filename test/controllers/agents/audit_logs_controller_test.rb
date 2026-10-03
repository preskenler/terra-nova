require "test_helper"

module Agents
  class AuditLogsControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot access the audit log" do
      sign_in users(:citizen)
      get agents_audit_logs_url
      assert_response :redirect
    end

    test "agent changes are recorded with the acting agent and diff" do
      sign_in agents(:agent)
      demand = demands(:d01)

      patch agents_demand_url(demand), params: { demand: { triage_status: "in_progress" } }

      version = PaperTrail::Version.where(item_type: "Demand", item_id: demand.id).order(:created_at).last
      assert_not_nil version
      assert_equal "Agent:#{agents(:agent).id}", version.whodunnit
      assert version.changeset.key?("triage_status")
    end

    test "an agent lists and opens audit entries" do
      sign_in agents(:agent)
      patch agents_demand_url(demands(:f52)), params: { demand: { triage_status: "done" } }

      get agents_audit_logs_url
      assert_response :success
      assert_match "Demand", response.body

      version = PaperTrail::Version.where(item_type: "Demand").order(:created_at).last
      get agents_audit_log_url(version)
      assert_response :success
      assert_match "triage_status", response.body
    end
  end
end
