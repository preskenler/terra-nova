# frozen_string_literal: true

module Eco
  # Measures the weight of the platform's own assets so the environmental
  # diagnosis page (F57) can report real numbers, and the asset budget test
  # (F58) can enforce them.
  class Report
    JS_BUDGET = 500_000
    CSS_BUDGET = 200_000

    def self.call
      new.call
    end

    def call
      {
        css_bytes: bytes(Rails.root.glob("app/assets/builds/*.css")),
        js_bytes: bytes(Rails.root.glob("vendor/javascript/*.js")),
        application_css_bytes: bytes(Rails.root.glob("app/assets/builds/application*.css")),
        js_budget: JS_BUDGET,
        css_budget: CSS_BUDGET
      }
    end

    private

    def bytes(paths)
      paths.sum { |path| File.size?(path).to_i }
    end
  end
end
