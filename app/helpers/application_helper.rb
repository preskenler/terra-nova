module ApplicationHelper
  # Maps a demand triage status to a UI badge variant. Colour is never the only
  # signal: the badge always carries the translated status text.
  def triage_variant(status)
    case status.to_s
    when "done"        then :success
    when "in_progress" then :info
    when "planned"     then :primary
    when "reviewing"   then :warning
    when "ignored"     then :neutral
    else :neutral
    end
  end

  # Maps a citizen request status to a badge variant (text always present).
  def request_badge_variant(status)
    case status.to_s
    when "resolved"    then :success
    when "in_progress" then :info
    when "acknowledged" then :primary
    when "closed", "rejected" then :neutral
    else :warning
    end
  end

  def request_user_link(user)
    return "—" if user.blank?

    link_to user.email, agents_user_path(user), class: "link"
  end

  def appointment_badge_variant(status)
    case status.to_s
    when "confirmed" then :success
    when "requested" then :warning
    when "completed" then :info
    when "cancelled", "no_show" then :error
    else :neutral
    end
  end

  # Severity styling shared by announcements and alerts. Colour is never the
  # only signal: badges always carry the translated severity text.
  def severity_badge_variant(severity)
    case severity.to_s
    when "critical" then :error
    when "alert"    then :warning
    else :info
    end
  end

  def severity_alert_class(severity)
    case severity.to_s
    when "critical" then "alert-error"
    when "alert"    then "alert-warning"
    else "alert-info"
    end
  end

  # Resolves a PaperTrail whodunnit ("Agent:1" / "User:2") to a readable label.
  def audit_actor_label(whodunnit)
    return t("agents.audit_logs.system") if whodunnit.blank?

    type, id = whodunnit.split(":", 2)
    case type
    when "Agent"
      agent = Agent.find_by(id: id)
      agent ? t("agents.audit_logs.agent", email: agent.email) : whodunnit
    when "User"
      user = User.find_by(id: id)
      user ? link_to(user.email, agents_user_path(user), class: "link") : whodunnit
    else
      whodunnit
    end
  end
end
