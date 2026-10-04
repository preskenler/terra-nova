# frozen_string_literal: true

module Services
  # Aggregates how much each municipal service is used, so administrators and
  # agents can see the most used services as a clear, actionable ranking rather
  # than raw data (F98).
  #
  # "Usage" combines citizen requests, appointments and reviews attributed to a
  # service. The result is deliberately explicit: a ranked list with counts and
  # a plain-language summary sentence.
  class Usage
    Row = Struct.new(:service, :requests, :appointments, :reviews, :total, keyword_init: true)

    def self.call(limit: 10)
      new(limit: limit).call
    end

    def initialize(limit: 10)
      @limit = limit
    end

    # @return [Hash] { rows: [Row], total_requests:, period_note:, top: Row|nil }
    def call
      request_counts     = Request.where.not(service_id: nil).group(:service_id).count
      appointment_counts = Appointment.where.not(service_id: nil).group(:service_id).count
      review_counts      = ServiceReview.group(:service_id).count

      rows = Service.order(:slug).map do |service|
        requests = request_counts.fetch(service.id, 0)
        appointments = appointment_counts.fetch(service.id, 0)
        reviews = review_counts.fetch(service.id, 0)
        Row.new(
          service: service,
          requests: requests,
          appointments: appointments,
          reviews: reviews,
          total: requests + appointments + reviews
        )
      end

      rows = rows.sort_by { |row| -row.total }.first(@limit)

      {
        rows: rows,
        total_requests: request_counts.values.sum,
        top: rows.first,
        max_total: rows.map(&:total).max || 0
      }
    end
  end
end
