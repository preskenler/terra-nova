require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "triage variants cover every status" do
    assert_equal :success, triage_variant("done")
    assert_equal :info, triage_variant("in_progress")
    assert_equal :primary, triage_variant("planned")
    assert_equal :warning, triage_variant("reviewing")
    assert_equal :neutral, triage_variant("ignored")
    assert_equal :neutral, triage_variant("unseen")
  end

  test "request badge variants cover every status" do
    assert_equal :success, request_badge_variant("resolved")
    assert_equal :info, request_badge_variant("in_progress")
    assert_equal :primary, request_badge_variant("acknowledged")
    assert_equal :neutral, request_badge_variant("closed")
    assert_equal :neutral, request_badge_variant("rejected")
    assert_equal :warning, request_badge_variant("submitted")
  end

  test "priority and appointment variants" do
    assert_equal :error, request_priority_variant("urgent")
    assert_equal :neutral, request_priority_variant("normal")

    assert_equal :success, appointment_badge_variant("confirmed")
    assert_equal :warning, appointment_badge_variant("requested")
    assert_equal :info, appointment_badge_variant("completed")
    assert_equal :error, appointment_badge_variant("cancelled")
    assert_equal :error, appointment_badge_variant("no_show")
    assert_equal :neutral, appointment_badge_variant("other")
  end

  test "severity variants and alert classes" do
    assert_equal :error, severity_badge_variant("critical")
    assert_equal :warning, severity_badge_variant("alert")
    assert_equal :info, severity_badge_variant("info")

    assert_equal "alert-error", severity_alert_class("critical")
    assert_equal "alert-warning", severity_alert_class("alert")
    assert_equal "alert-info", severity_alert_class("info")
  end

  test "feedback, project, consultation and idea variants" do
    assert_equal :success, feedback_badge_variant("resolved")
    assert_equal :info, feedback_badge_variant("in_review")
    assert_equal :warning, feedback_badge_variant("new")

    assert_equal :primary, project_status_variant(projects(:park))
    assert_equal :info, project_status_variant(projects(:tram))

    assert_equal :success, consultation_status_variant(consultations(:park_opinion))
    assert_equal :neutral, consultation_status_variant(consultations(:closed_survey))

    idea = ideas(:compost)
    assert_equal :warning, idea_status_variant(idea)
    assert_equal :info, idea_status_variant(idea.tap { |i| i.status = "under_review" })
    assert_equal :success, idea_status_variant(idea.tap { |i| i.status = "accepted" })
    assert_equal :error, idea_status_variant(idea.tap { |i| i.status = "declined" })
  end

  test "service status variant" do
    assert_equal :success, service_status_variant(services(:etat_civil))
    assert_equal :warning, service_status_variant(services(:water_maintenance))
    assert_equal :neutral, service_status_variant(services(:closed))
  end

  test "audit actor label resolves agents, users and blanks" do
    agent = agents(:agent)
    user = users(:citizen)

    assert_match agent.email, audit_actor_label("Agent:#{agent.id}")
    assert_match user.email, audit_actor_label("User:#{user.id}")
    assert_equal t("agents.audit_logs.system"), audit_actor_label(nil)
    assert_equal "Unknown:1", audit_actor_label("Unknown:1")
    assert_equal "Agent:999999", audit_actor_label("Agent:999999")
  end

  test "request user link handles present and blank users" do
    assert_equal "—", request_user_link(nil)
    assert_match users(:citizen).email, request_user_link(users(:citizen))
  end

  test "form protection fields render a honeypot and a token" do
    html = form_protection_fields

    assert_match "website", html
    assert_match "form_token", html
  end
end
