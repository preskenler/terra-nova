# frozen_string_literal: true

module Exports
  # Produces a verifiable backup of the important platform data (F87).
  #
  # The result is deliberately *clear and actionable* rather than a raw dump:
  # a readable CSV whose first rows summarise what was exported, when, and by
  # whom, followed by the request records themselves. It reuses the existing
  # Requests::Csv exporter so administrators can confirm the data can be saved
  # and restored.
  class Requests
    def initialize(scope: nil, generated_at: Time.current, actor: nil)
      @scope = scope || Request.includes(:user, :service).recent_first
      @generated_at = generated_at
      @actor = actor
    end

    # @return [String] CSV content
    def call
      records = @scope.to_a

      csv = +""
      csv << summary_rows(records)
      csv << "\n"
      csv << ::Requests::Csv.call(records, detailed: true)
      csv
    end

    # A short, human-readable summary of the export, so the file is exploitable
    # on its own (never just raw data).
    def summary
      base = @scope.unscope(:order)
      {
        generated_at: @generated_at,
        generated_by: @actor&.email,
        total: base.count,
        by_status: base.group(:status).count,
        urgent: base.where(priority: "urgent").count,
        earliest: base.minimum(:created_at),
        latest: base.maximum(:created_at)
      }
    end

    def filename
      "sauvegarde-demandes-#{@generated_at.to_date}.csv"
    end

    private

    def summary_rows(records)
      data = summary
      [
        title_line,
        line(t("generated_at"), value: I18n.l(data[:generated_at], format: :long)),
        line(t("generated_by"), value: data[:generated_by].presence || "—"),
        line(t("total"), value: data[:total]),
        line(t("urgent"), value: data[:urgent]),
        line(t("period"), value: period(data)),
        line(t("by_status"), value: status_breakdown(records))
      ].join
    end

    def title_line
      %("#{I18n.t("agents.exports.requests.title")}"\n)
    end

    def line(label, value:)
      %("#{label}";"#{value}"\n)
    end

    def t(key)
      I18n.t("agents.exports.requests.#{key}")
    end

    def period(data)
      return "—" if data[:earliest].blank?

      "#{I18n.l(data[:earliest], format: :short)} → #{I18n.l(data[:latest], format: :short)}"
    end

    def status_breakdown(records)
      records.group_by(&:status)
             .map { |status, group| "#{I18n.t("requests.status.#{status}")}: #{group.size}" }
             .join(", ")
    end
  end
end
