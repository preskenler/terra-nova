module ApplicationHelper
  # Renders the anti-automation fields shared by public forms (F81): an
  # off-screen honeypot plus a signed render-time token.
  def form_protection_fields
    honeypot = content_tag(:div, class: "sr-only", "aria-hidden": "true") do
      text_field_tag(FormProtection::HONEYPOT_FIELD, nil, tabindex: -1, autocomplete: "off")
    end
    safe_join([ honeypot, hidden_field_tag(:form_token, FormProtection.form_protection_token) ])
  end

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

  def request_priority_variant(priority)
    priority.to_s == "urgent" ? :error : :neutral
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

  def feedback_badge_variant(status)
    case status.to_s
    when "resolved"  then :success
    when "in_review" then :info
    else :warning
    end
  end

  # Pinned site-wide announcements, cached briefly (F73/F77).
  def pinned_announcements
    @pinned_announcements ||= Rails.cache.fetch("announcements:pinned", expires_in: 5.minutes) do
      Announcement.published.pinned.recent_first.limit(2).to_a
    end
  end

  def service_status_variant(service)
    return :success if service.active?
    return :warning if service.maintenance?

    :neutral
  end

  def project_status_variant(project)
    return :primary if project.ongoing?
    return :info if project.planned?

    :neutral
  end

  def consultation_status_variant(consultation)
    return :success if consultation.open_for_response?
    return :info if consultation.open?

    :neutral
  end

  def idea_status_variant(idea)
    case idea.status.to_s
    when "accepted"     then :success
    when "under_review" then :info
    when "declined"     then :error
    else :warning
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
