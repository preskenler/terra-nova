# frozen_string_literal: true

module Ui
  # "Skip to main content" link, visible only when focused. First focusable
  # element on the page for keyboard/screen-reader users.
  class SkipLinkComponent < ApplicationComponent
    def initialize(target: "main-content")
      @target = target
    end
  end
end
