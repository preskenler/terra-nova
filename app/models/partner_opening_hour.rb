# frozen_string_literal: true

class PartnerOpeningHour < ApplicationRecord
  belongs_to :partner

  validates :wday, inclusion: { in: 0..6 }

  scope :ordered, -> { order(:wday) }

  def label
    return I18n.t("partners.closed") if closed? || opens_at.blank?

    [ opens_at, closes_at ].compact.join(" – ")
  end
end
