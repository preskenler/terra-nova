# frozen_string_literal: true

module Appointments
  # Computes the bookable start times for an agent on a given date, based on
  # their weekly availability, time off and existing appointments (F39).
  class AvailableSlots
    LEAD_TIME = 1.hour

    def initialize(agent:, date:, service_id: nil)
      @agent = agent
      @date = date
      @service_id = service_id
    end

    # @return [Array<ActiveSupport::TimeWithZone>]
    def call
      return [] if @agent.blank? || @date.blank?

      availability = @agent.agent_availabilities.active.find_by(wday: @date.wday)
      return [] if availability.nil?

      step = (availability.slot_minutes.presence || 30).to_i
      cursor = time_on_day(availability.start_time)
      closing = time_on_day(availability.end_time)

      slots = []
      while cursor + step.minutes <= closing
        slots << cursor if available?(cursor, step)
        cursor += step.minutes
      end
      slots
    end

    private

    def time_on_day(time)
      Time.zone.local(@date.year, @date.month, @date.day, time.hour, time.min)
    end

    def available?(start_at, step)
      return false if start_at < Time.current + LEAD_TIME

      finish = start_at + step.minutes
      return false if @agent.agent_time_offs
                                .where("starts_at < ? AND ends_at > ?", finish, start_at)
                                .exists?

      Appointment
        .where(agent_id: @agent.id, status: %w[requested confirmed])
        .where("starts_at < ? AND ends_at > ?", finish, start_at)
        .none?
    end
  end
end
