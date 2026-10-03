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
end
