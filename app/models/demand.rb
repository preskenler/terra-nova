# A demand broadcast by the external Webcup "Terra Nova" API.
#
# This is NOT a citizen request (see +Request+). Demands are the functional
# requirements issued during the 24h event; the agent workspace surfaces and
# triages them. +request_code+ is the stable business key used for upserts.
class Demand < ApplicationRecord
  has_paper_trail ignore: %i[last_seen_at raw_payload updated_at]

  belongs_to :assignee, class_name: "Agent", optional: true

  DIFFICULTY_LABELS = { 1 => "Facile", 2 => "Moyenne", 3 => "Difficile", 4 => "Expert" }.freeze
  TRIAGE_STATUSES = %w[unseen reviewing planned in_progress done ignored].freeze

  enum :triage_status, TRIAGE_STATUSES.index_with(&:itself), default: :unseen, validate: true

  validates :request_code, presence: true, uniqueness: true
  validates :message_public, presence: true

  scope :recently_seen, -> { order(last_seen_at: :desc, id: :desc) }
  scope :by_wave, ->(wave) { where(wave_number: wave) }
  scope :by_difficulty, ->(level) { where(difficulty_level: level) }
  scope :pending_triage, -> { where(triage_status: %w[unseen reviewing planned in_progress]) }
  scope :new_arrivals, -> { where(triage_status: "unseen") }

  def difficulty_label
    difficulty.presence || DIFFICULTY_LABELS[difficulty_level]
  end

  def xp
    xp_available.presence || xp_total
  end

  def initial?
    is_initial?
  end
end
