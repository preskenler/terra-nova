# frozen_string_literal: true

# Static trust, accessibility and environmental pages.
class PagesController < ApplicationController
  def transparency
  end

  def accessibility
  end

  # Environmental diagnosis and weight report (F57/F58).
  def eco
    @report = Eco::Report.call
  end
end
