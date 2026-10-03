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
end
