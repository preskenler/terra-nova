# frozen_string_literal: true

require "zlib"

module Eco
  # Measures the weight of the platform's own assets so the environmental
  # diagnosis page (F57) can report real numbers, and the asset budget test
  # (F58) can enforce them.
  #
  # Budgets are enforced on the *gzipped* size (what a browser actually
  # downloads), which is stable regardless of whether the local build is
  # minified.
  class Report
    CSS_BUDGET = 80_000
    JS_BUDGET = 80_000

    def self.call
      new.call
    end

    def call
      css_paths = Rails.root.glob("app/assets/builds/*.css")
      js_paths = Rails.root.glob("vendor/javascript/*.js")

      {
        css_bytes: bytes(css_paths),
        js_bytes: bytes(js_paths),
        css_gzip_bytes: gzip_bytes(css_paths),
        js_gzip_bytes: gzip_bytes(js_paths),
        css_budget: CSS_BUDGET,
        js_budget: JS_BUDGET
      }
    end

    private

    def bytes(paths)
      paths.sum { |path| File.size?(path).to_i }
    end

    def gzip_bytes(paths)
      paths.sum { |path| Zlib.gzip(File.binread(path)).bytesize }
    end
  end
end
