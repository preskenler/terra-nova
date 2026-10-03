# frozen_string_literal: true

module Ui
  class FlashComponent < ApplicationComponent
    def initialize(flash:)
      @notice = flash[:notice]
      @alert = flash[:alert]
    end

    def any?
      @notice.present? || @alert.present?
    end
  end
end
