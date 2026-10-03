# frozen_string_literal: true

module Ui
  class CardComponent < ApplicationComponent
    def initialize(title: nil, subtitle: nil, **options)
      @title = title
      @subtitle = subtitle
      @options = options
    end
  end
end
