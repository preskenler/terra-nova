# frozen_string_literal: true

# Contact form to reach the municipal services (D04/F51).
class FeedbacksController < ApplicationController
  def new
    @feedback = Feedback.new(user: current_user, kind: params[:kind])
    authorize @feedback
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.user = current_user
    @feedback.email ||= current_user.email if current_user
    authorize @feedback

    if @feedback.save
      redirect_to root_path,
                  notice: t("feedbacks.created", reference: @feedback.reference)
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:kind, :email, :subject, :message)
  end
end
