# frozen_string_literal: true

class ServicesController < ApplicationController
  def index
    @query = params[:q]
    @category = params[:category]

    scope = Service.publicly_visible.ordered.search(@query)
    scope = scope.where(category: @category) if @category.present?

    @services = scope.to_a
    @priority_services = Service.publicly_visible.priorities.ordered.to_a
    @emergency_services = Service.publicly_visible.emergencies.ordered.to_a
    @categories = Service.publicly_visible.where.not(category: nil).distinct.order(:category).pluck(:category)
  end

  def show
    @service = Service.publicly_visible.find_by!(slug: params[:id])
    @related_services = Service.publicly_visible
                              .where(category: @service.category)
                              .where.not(id: @service.id)
                              .ordered.limit(3)
  end
end
