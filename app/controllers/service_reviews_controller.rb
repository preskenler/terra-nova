# frozen_string_literal: true

# A citizen leaves a comment after using a service (F76).
class ServiceReviewsController < ApplicationController
  include CitizenSpace

  def create
    service = Service.publicly_visible.find_by!(slug: params[:service_id])
    review = service.service_reviews.new(
      user: current_user,
      rating: params.dig(:service_review, :rating),
      comment: params.dig(:service_review, :comment)
    )

    if review.save
      current_user.notifications.create!(
        kind: "general", notifiable: review,
        title: t("notifications.review.title", reference: review.reference),
        body: t("notifications.review.body")
      )
      redirect_to service_path(service), notice: t("service_reviews.created", reference: review.reference)
    else
      redirect_to service_path(service), alert: review.errors.full_messages.to_sentence
    end
  end
end
