require "test_helper"

module Appointments
  class AvailableSlotsTest < ActiveSupport::TestCase
    test "generates slots for an available day" do
      slots = Appointments::AvailableSlots.new(agent: agents(:agent), date: next_monday).call

      assert slots.any?
      assert(slots.all? { |slot| slot.wday == 1 })
      assert(slots.all? { |slot| slot >= Time.zone.local(next_monday.year, next_monday.month, next_monday.day, 9, 0) })
    end

    test "excludes a slot already booked" do
      agent = agents(:agent)
      date = next_monday
      booked = Time.zone.local(date.year, date.month, date.day, 9, 0)
      agent.appointments.create!(user: users(:citizen), starts_at: booked, duration_minutes: 30)

      slots = Appointments::AvailableSlots.new(agent: agent, date: date).call

      assert_not_includes slots, booked
    end

    test "returns nothing when the agent has no availability that day" do
      # Tuesday (wday 2) has no availability fixture for this agent.
      tuesday = next_monday + 1.day
      assert_empty Appointments::AvailableSlots.new(agent: agents(:agent), date: tuesday).call
    end
  end
end
