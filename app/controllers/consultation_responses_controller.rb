# frozen_string_literal: true

# Records a citizen's answer to a consultation (F65/F66).
class ConsultationResponsesController < ApplicationController
  include CitizenSpace

  def create
    consultation = Consultation.published.find(params[:consultation_id])

    unless consultation.open_for_response?
      return redirect_to consultation_path(consultation), alert: t("consultations.closed")
    end

    response = consultation.consultation_responses.new(
      user: current_user,
      choice: params.dig(:consultation_response, :choice),
      comment: params.dig(:consultation_response, :comment)
    )

    if response.save
      current_user.notifications.create!(
        kind: "general", notifiable: consultation,
        title: t("notifications.consultation.title", reference: response.reference),
        body: t("notifications.consultation.body")
      )
      redirect_to consultation_path(consultation), notice: t("consultations.recorded", reference: response.reference)
    else
      redirect_to consultation_path(consultation), alert: response.errors.full_messages.to_sentence
    end
  end
end
