# frozen_string_literal: true

class GlossaryController < ApplicationController
  def index
    @terms = GlossaryTerm.ordered.to_a
  end
end
