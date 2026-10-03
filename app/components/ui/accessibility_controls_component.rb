# frozen_string_literal: true

module Ui
  # High-contrast and large-text controls (D20/F23/F24/F43/F44).
  class AccessibilityControlsComponent < ApplicationComponent
    def initialize(high_contrast:, large_text:)
      @high_contrast = high_contrast
      @large_text = large_text
    end
  end
end
