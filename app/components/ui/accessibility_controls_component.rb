# frozen_string_literal: true

module Ui
  # High-contrast, large-text and low-data controls (D20/F23/F24/F43/F44/F59).
  class AccessibilityControlsComponent < ApplicationComponent
    def initialize(high_contrast:, large_text:, reduced_data: false)
      @high_contrast = high_contrast
      @large_text = large_text
      @reduced_data = reduced_data
    end
  end
end
