# frozen_string_literal: true

module Ui
  # Consistent page header (title + optional subtitle + optional actions block).
  class PageHeaderComponent < ApplicationComponent
    def initialize(title:, subtitle: nil)
      @title = title
      @subtitle = subtitle
    end
  end
end
