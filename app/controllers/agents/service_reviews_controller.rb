# frozen_string_literal: true

module Agents
  # Moderate the comments citizens leave after using a service (F76).
  class ServiceReviewsController < BaseController
    def index
      authorize ServiceReview
      @reviews = ServiceReview.includes(:service, :user).recent_first.limit(200)
    end

    def update
      @review = ServiceReview.find_by!(reference: params[:id])
      authorize @review

      if @review.update(status: params[:service_review][:status])
        redirect_to agents_service_reviews_path, notice: t("agents.service_reviews.updated")
      else
        redirect_to agents_service_reviews_path, alert: t("agents.service_reviews.invalid")
      end
    end
  end
end
