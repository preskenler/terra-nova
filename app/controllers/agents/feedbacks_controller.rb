# frozen_string_literal: true

module Agents
  # Handle messages received from citizens (D04/F51).
  class FeedbacksController < BaseController
    before_action :set_feedback, only: [ :show, :update ]

    def index
      authorize Feedback

      scope = Feedback.recent_first
      scope = scope.where(status: params[:status]) if params[:status].present?
      scope = scope.where(kind: params[:kind]) if params[:kind].present?

      @feedbacks = scope.limit(200).to_a
      @counts = Feedback.group(:status).count
    end

    def show
      authorize @feedback
    end

    def update
      authorize @feedback

      if @feedback.update(feedback_params)
        notify_user(@feedback)
        redirect_to agents_feedback_path(@feedback), notice: t("agents.feedbacks.updated")
      else
        render :show, status: :unprocessable_content
      end
    end

    private

    def set_feedback
      @feedback = Feedback.find_by!(reference: params[:id])
    end

    def feedback_params
      params.require(:feedback).permit(:status, :agent_notes)
    end

    def notify_user(feedback)
      return if feedback.user.blank?

      feedback.user.notifications.create!(
        kind: "general",
        notifiable: feedback,
        title: t("notifications.feedback.title", reference: feedback.reference),
        body: t("notifications.feedback.body", status: t("feedbacks.status.#{feedback.status}"))
      )
    end
  end
end
