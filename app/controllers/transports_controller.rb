# frozen_string_literal: true

class TransportsController < ApplicationController
  def index
    @lines = TransportLine.active.ordered.to_a
  end
end
