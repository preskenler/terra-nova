# frozen_string_literal: true

# Plain-language definition of a term used on the platform (D13).
class GlossaryTerm < ApplicationRecord
  include Translatable
  translates :term, :definition

  validates :term, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :ensure_slug

  scope :ordered, -> { order(:slug) }

  def to_param
    slug
  end

  private

  def ensure_slug
    return if slug.present?

    self.slug = (term_fr.presence || term_en.presence || term.to_s).parameterize
  end
end
