# frozen_string_literal: true

# A partner (association, business, service provider) with a location and
# opening hours (F74).
class Partner < ApplicationRecord
  include Translatable
  has_paper_trail ignore: %i[updated_at]

  translates :name, :description

  CATEGORIES = %w[sante commerce culture sport social transport loisirs autres].freeze

  has_many :partner_opening_hours, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

  before_validation :ensure_slug

  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(:category, :slug) }

  def to_param
    slug
  end

  def location?
    latitude.present? && longitude.present?
  end

  def hours_for(wday)
    partner_opening_hours.find_by(wday: wday)
  end

  private

  def ensure_slug
    return if slug.present?

    self.slug = (name_fr.presence || name_en.presence || name.to_s).parameterize
  end
end
