# frozen_string_literal: true

# A municipal project citizens can consult (F67).
class Project < ApplicationRecord
  include Translatable
  has_paper_trail ignore: %i[updated_at]

  translates :name, :description

  CATEGORIES = %w[urbanisme environnement mobilite social culture economie autres].freeze
  STATUSES = { planned: "planned", ongoing: "ongoing", completed: "completed" }.freeze

  enum :status, STATUSES, default: :planned, validate: true

  has_many :consultations, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

  before_validation :ensure_slug

  scope :published, -> { where(published: true) }
  scope :ongoing, -> { where(status: "ongoing") }
  scope :ordered, -> { order(starts_on: :desc, created_at: :desc) }

  def to_param
    slug
  end

  private

  def ensure_slug
    return if slug.present?

    self.slug = (name_fr.presence || name_en.presence || name.to_s).parameterize
  end
end
