# frozen_string_literal: true

module Ui
  class EmptyStateComponent < ApplicationComponent
    def initialize(title:, description: nil)
      @title = title
      @description = description
    end
  end
end
