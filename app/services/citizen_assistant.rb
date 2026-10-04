# frozen_string_literal: true

require "set"

# Heuristic orientation assistant (F91/F92).
#
# It is deliberately dependency-free and explainable (no external AI call): it
# tokenises the citizen's free-text need, scores municipal services and glossary
# terms by keyword overlap, and returns the most relevant service plus a
# suggested first step. It tolerates imperfect wording by matching on loose
# tokens and by mapping common situations to services (see CitizenGuidance).
class CitizenAssistant
  STOPWORDS = %w[
    le la les un une des de du au aux et ou pour avec sans sur dans par est
    sont je j ai mon ma mes nous vous il elle ce cet cette qui que quoi ou
    comment faire peux peut besoin voudrais aimerais savoir ou est
    the and for with from this that a an of to in on my i you we is are can
    need want how what where help please
  ].to_set.freeze

  # Keywords that, when present, push a service category up.
  CATEGORY_KEYWORDS = {
    "etat_civil" => %w[acte naissance mariage deces livret certificat recensement],
    "urbanisme" => %w[permis construire travaux cloture urbanisme plan],
    "sante" => %w[sante medecin vaccin soin prevention docteur],
    "urgence" => %w[urgence danger pompiers samu secours 112],
    "dechets" => %w[dechets poubelle collecte encombrant compost recyclage],
    "transports" => %w[bus tram navette horaire abonnement transport arret],
    "social" => %w[aide social famille personne agee precarite],
    "environnement" => %w[parc jardin vert lampadaire eau voirie trottoir chaussee]
  }.freeze

  SUGGESTED_REQUEST = {
    "environnement" => :report_problem,
    "dechets" => :report_problem,
    "etat_civil" => :request_document
  }.freeze

  def self.call(query)
    new(query).call
  end

  def initialize(query)
    @query = query.to_s
  end

  # @return [Hash] with the query, ranked services and a suggested step.
  def call
    tokens = tokenize(@query)

    return empty_result if tokens.empty?

    {
      query: @query,
      services: ranked_services(tokens),
      suggested_step: suggested_step(tokens)
    }
  end

  private

  def empty_result
    { query: @query, services: [], suggested_step: nil }
  end

  def ranked_services(tokens)
    Service.publicly_visible.ordered
           .to_a
           .filter_map { |service| [ service, score(service, tokens) ] }
           .select { |_service, value| value.positive? }
           .sort_by { |_service, value| -value }
           .first(5)
           .map(&:first)
  end

  def score(service, tokens)
    haystack = tokenize(
      [
        service.name.to_s,
        service.description.to_s,
        service.plain_language.to_s,
        service.category.to_s,
        (CATEGORY_KEYWORDS[service.category] || []).join(" ")
      ].join(" ")
    )

    overlap = tokens.count { |token| haystack.any? { |word| fuzzy_match?(token, word) } }
    category_boost = if (CATEGORY_KEYWORDS[service.category] || []).any? { |word| tokens.any? { |t| fuzzy_match?(t, word) } }
                       2
    else
                       0
    end
    priority_boost = service.priority? ? 0.5 : 0

    return 0 if overlap.zero? && category_boost.zero?

    overlap + category_boost + priority_boost
  end

  # Tolerates imperfect wording: a token matches when it is equal to, or a
  # common prefix of, a haystack word (e.g. "poubell" ~ "poubelle").
  def fuzzy_match?(token, word)
    return true if token == word
    return false if token.length < 4 || word.length < 4

    token.start_with?(word) || word.start_with?(token)
  end

  def suggested_step(tokens)
    best = CATEGORY_KEYWORDS.find { |_category, words| words.any? { |word| tokens.include?(word) } }
    return nil unless best

    type = SUGGESTED_REQUEST[best.first] || :contact
    { type: type, category: best.first }
  end

  def tokenize(text)
    text.to_s.downcase.scan(/[[:alnum:]]+/).reject { |t| t.length < 3 || STOPWORDS.include?(t) }.to_set
  end
end
