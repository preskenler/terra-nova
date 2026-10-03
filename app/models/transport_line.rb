# frozen_string_literal: true

# Municipal transport line with schedules and disruptions (F36).
class TransportLine < ApplicationRecord
  include Translatable
  has_paper_trail ignore: %i[updated_at]

  translates :name, :description

  MODES = %w[bus tram metro navette].freeze

  enum :mode, { bus: "bus", tram: "tram", metro: "metro", navette: "navette" },
       default: :bus, validate: true

  has_many :transport_schedules, dependent: :destroy
  has_many :transport_disruptions, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :ensure_slug

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:mode, :slug) }

  def to_param
    slug
  end

  def current_disruptions
    transport_disruptions.active_now.order(created_at: :desc)
  end

  private

  def ensure_slug
    return if slug.present?

    self.slug = (name_fr.presence || name_en.presence || name.to_s).parameterize
  end
end
