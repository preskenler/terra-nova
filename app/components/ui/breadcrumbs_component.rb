# frozen_string_literal: true

module Ui
  # Accessible breadcrumb navigation (D15).
  # +items+ is an array of hashes: { label:, path: } (path optional on the last).
  class BreadcrumbsComponent < ApplicationComponent
    def initialize(items:)
      @items = items
    end
  end
end
