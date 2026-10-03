# frozen_string_literal: true

module Ui
  # Status / category badge. Variants map to daisyUI semantic badge classes.
  class BadgeComponent < ApplicationComponent
    VARIANTS = {
      neutral: "badge-ghost",
      info: "badge-info",
      success: "badge-success",
      warning: "badge-warning",
      error: "badge-error",
      primary: "badge-primary"
    }.freeze

    def initialize(label:, variant: :neutral, size: nil, **options)
      @label = label
      @variant = variant
      @size = size
      @options = options
    end

    def css_class
      [ "badge", VARIANTS.fetch(@variant, VARIANTS[:neutral]),
        (@size ? "badge-#{@size}" : nil), @options[:class] ].compact.join(" ")
    end
  end
end
