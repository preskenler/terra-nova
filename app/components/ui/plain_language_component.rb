# frozen_string_literal: true

module Ui
  # A plain-language summary of essential information (F89), disclosed on demand
  # with a native <details> element so it needs no JavaScript and stays closed
  # for visitors who do not need it (F90).
  class PlainLanguageComponent < ApplicationComponent
    def initialize(text:)
      @text = text
    end

    def render?
      @text.present?
    end
  end
end
