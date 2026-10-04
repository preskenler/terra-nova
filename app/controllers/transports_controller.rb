# frozen_string_literal: true

class TransportsController < ApplicationController
  def index
    @lines = TransportLine.active.ordered.to_a
    # F97 : lignes actuellement interrompues, avec une solution de remplacement.
    @disruptions = TransportDisruption
                     .includes(:transport_line)
                     .active_now
                     .order(Arel.sql("CASE severity WHEN 'critical' THEN 0 WHEN 'warning' THEN 1 ELSE 2 END"))
                     .to_a
  end
end
