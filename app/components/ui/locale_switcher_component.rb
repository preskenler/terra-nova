# frozen_string_literal: true

module Ui
  # Language switcher (D14). Submits on change via a small Stimulus controller
  # and always exposes a real submit button for keyboard/no-JS users.
  class LocaleSwitcherComponent < ApplicationComponent
    def initialize(current:)
      @current = current
    end
  end
end
