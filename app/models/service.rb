# frozen_string_literal: true

# A municipal service presented to citizens (D05/D07/F27/F28/F32/F38/F46).
class Service < ApplicationRecord
  include Translatable
  has_paper_trail ignore: %i[updated_at]

  translates :name, :description, :maintenance_message

  CATEGORIES = %w[
    etat_civil urbanisme sante urgence dechets transports
    social loisirs environnement autres
  ].freeze

  enum :status, { active: "active", maintenance: "maintenance", inactive: "inactive" },
       default: :active, validate: true

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

  before_validation :ensure_slug

  has_many :requests, dependent: :nullify
  has_many :appointments, dependent: :nullify

  # Priority/common services first (F28).
  scope :ordered, -> { order(priority: :desc, created_at: :asc) }
  # Inactive services are hidden from the public catalog.
  scope :publicly_visible, -> { where(status: %w[active maintenance]) }
  scope :priorities, -> { where(priority: true) }
  scope :emergencies, -> { where(emergency: true) }
  scope :search, lambda { |query|
    next all if query.blank?

    pattern = "%#{query.strip}%"
    where("slug LIKE :q OR name_translations LIKE :q OR description_translations LIKE :q", q: pattern)
  }

  def to_param
    slug
  end

  def location?
    latitude.present? && longitude.present?
  end

  private

  def ensure_slug
    return if slug.present?

    self.slug = (name_fr.presence || name_en.presence || name.to_s).parameterize
  end
end
