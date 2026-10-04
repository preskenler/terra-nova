# frozen_string_literal: true

module Security
  # Detects unusual activity from the existing security-event trail (F85).
  #
  # It does not add a new monitoring subsystem: it aggregates the events already
  # recorded (blocked automated submissions, failed sign-ins, …) over a recent
  # window and flags spikes. This makes the protection perceptible in real use
  # without complicating normal usage: an administrator sees at a glance whether
  # something looks off, and which events/addresses are involved.
  class EventsSummary
    # An event is "suspicious" when it occurs at least this many times in the
    # window. Chosen so a handful of legitimate mistakes never raises a flag.
    THRESHOLDS = {
      "form_protection_blocked" => 5,
      "sign_in_failed" => 10
    }.freeze
    DEFAULT_THRESHOLD = 20

    def initialize(period: 1.hour)
      @period = period
    end

    # @return [Hash] an explicit, display-ready summary
    def call
      {
        period: @period,
        window_start: window_start,
        total: total,
        counts: counts,
        signals: signals,
        top_ips: top_ips,
        suspicious: signals.any?
      }
    end

    def suspicious?
      signals.any?
    end

    private

    def window_start
      @window_start ||= @period.ago
    end

    def events
      @events ||= SecurityEvent.where(created_at: window_start..)
    end

    def counts
      @counts ||= events.group(:event).count
    end

    def total
      counts.values.sum
    end

    # Events whose recent volume exceeds their threshold, sorted by excess.
    def signals
      @signals ||= counts
                   .select { |event, count| count >= threshold_for(event) }
                   .sort_by { |_event, count| -count }
                   .to_h
    end

    def top_ips
      events.where.not(ip: [ nil, "" ])
            .group(:ip)
            .order(Arel.sql("COUNT(*) DESC"))
            .limit(5)
            .count
    end

    def threshold_for(event)
      THRESHOLDS.fetch(event.to_s, DEFAULT_THRESHOLD)
    end
  end
end
