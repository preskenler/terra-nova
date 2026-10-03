# frozen_string_literal: true

module Agents
  # Manage the service catalog and quickly disable a faulty service (F63).
  class ServicesController < BaseController
    before_action :set_service, only: [ :edit, :update, :disable, :enable ]

    def index
      authorize Service
      @services = Service.order(:slug)
    end

    def edit
      authorize @service
    end

    def update
      authorize @service

      if @service.update(service_params)
        redirect_to agents_services_path, notice: t("agents.services.updated", name: @service.name)
      else
        render :edit, status: :unprocessable_content
      end
    end

    # One-click disable: puts the service under maintenance immediately (F63).
    def disable
      authorize @service
      @service.update(status: "maintenance")
      redirect_to agents_services_path, notice: t("agents.services.disabled", name: @service.name)
    end

    def enable
      authorize @service
      @service.update(status: "active")
      redirect_to agents_services_path, notice: t("agents.services.enabled", name: @service.name)
    end

    private

    def set_service
      @service = Service.find_by!(slug: params[:id])
    end

    def service_params
      params.require(:service).permit(
        :status, :priority, :emergency, :expected_return, :contact_phone, :contact_email,
        :maintenance_message_fr, :maintenance_message_en
      )
    end
  end
end
