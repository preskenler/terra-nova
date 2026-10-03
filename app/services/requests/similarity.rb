# frozen_string_literal: true

require "set"

module Requests
  # Finds open requests that likely describe the same problem, so agents can
  # spot duplicates quickly (F75). Simple, explainable heuristic: keyword
  # overlap (Jaccard) plus a boost for the same service or location.
  class Similarity
    STOPWORDS = %w[
      the and for with from this that une des les dans pour avec sur par est
      sont aux plus pas tres very has have has been was were are
    ].to_set.freeze

    THRESHOLD = 0.34

    def initialize(request)
      @request = request
    end

    def call
      Request
        .where.not(id: @request.id)
        .where(status: Request::OPEN_STATUSES)
        .to_a
        .select { |other| score(other) >= THRESHOLD }
        .sort_by { |other| -score(other) }
        .first(5)
    end

    private

    def score(other)
      tokens_a = tokens("#{@request.subject} #{@request.description}")
      tokens_b = tokens("#{other.subject} #{other.description}")
      return 0.0 if tokens_a.empty? || tokens_b.empty?

      jaccard = (tokens_a & tokens_b).size.to_f / (tokens_a | tokens_b).size
      boost = 0.0
      boost += 0.2 if @request.service_id.present? && @request.service_id == other.service_id
      boost += 0.2 if @request.location_text.present? && @request.location_text == other.location_text
      jaccard + boost
    end

    def tokens(text)
      text.to_s.downcase.scan(/[[:alnum:]]+/).reject { |token| token.length < 3 || STOPWORDS.include?(token) }.to_set
    end
  end
end
