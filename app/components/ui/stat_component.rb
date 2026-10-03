# frozen_string_literal: true

module Ui
  class StatComponent < ApplicationComponent
    def initialize(label:, value:, hint: nil, emphasis: false)
      @label = label
      @value = value
      @hint = hint
      @emphasis = emphasis
    end
  end
end
