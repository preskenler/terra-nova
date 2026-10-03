# frozen_string_literal: true

module Ui
  # Consistent section heading with the civic accent bar.
  class SectionHeadingComponent < ApplicationComponent
    def initialize(title:, id: nil)
      @title = title
      @id = id
    end
  end
end
