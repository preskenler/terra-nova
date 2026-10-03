# frozen_string_literal: true

module Agents
  # Manage consultations and view their results (F65/F66).
  class ConsultationsController < BaseController
    before_action :set_consultation, only: [ :show, :edit, :update, :destroy ]

    def index
      authorize Consultation
      @consultations = Consultation.recent_first
    end

    def show
      authorize @consultation
      @responses = @consultation.consultation_responses.includes(:user).recent_first
      @choice_counts = @consultation.consultation_responses.group(:choice).count
    end

    def new
      @consultation = Consultation.new(status: "open", opens_at: Time.current)
      authorize @consultation
    end

    def create
      @consultation = Consultation.new(consultation_params)
      authorize @consultation

      if @consultation.save
        redirect_to agents_consultation_path(@consultation), notice: t("agents.consultations.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @consultation
    end

    def update
      authorize @consultation

      if @consultation.update(consultation_params)
        redirect_to agents_consultation_path(@consultation), notice: t("agents.consultations.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @consultation
      @consultation.destroy
      redirect_to agents_consultations_path, notice: t("agents.consultations.destroyed")
    end

    private

    def set_consultation
      @consultation = Consultation.find(params[:id])
    end

    def consultation_params
      params.require(:consultation).permit(
        :project_id, :kind, :status, :opens_at, :closes_at,
        :title_fr, :title_en, :description_fr, :description_en
      )
    end
  end
end
