# frozen_string_literal: true

module Agents
  # Manage partners, their location and opening hours (F74).
  class PartnersController < BaseController
    before_action :set_partner, only: [ :show, :edit, :update, :destroy, :hours ]

    def index
      authorize Partner
      @partners = Partner.ordered
    end

    def show
      authorize @partner
      @hours = @partner.partner_opening_hours.index_by(&:wday)
    end

    def new
      @partner = Partner.new(published: true)
      authorize @partner
    end

    def create
      @partner = Partner.new(partner_params)
      authorize @partner

      if @partner.save
        redirect_to agents_partner_path(@partner), notice: t("agents.partners.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @partner
    end

    def update
      authorize @partner

      if @partner.update(partner_params)
        redirect_to agents_partner_path(@partner), notice: t("agents.partners.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @partner
      @partner.destroy
      redirect_to agents_partners_path, notice: t("agents.partners.destroyed")
    end

    # Bulk update of the seven weekday opening hours.
    def hours
      authorize @partner, :update?

      params.fetch(:opening_hours, {}).each do |wday, attrs|
        next unless wday.to_s.match?(/\A[0-6]\z/)

        record = @partner.partner_opening_hours.find_or_initialize_by(wday: wday.to_i)
        record.closed = attrs[:closed] == "1"
        record.opens_at = attrs[:opens_at]
        record.closes_at = attrs[:closes_at]
        record.save!
      end

      redirect_to agents_partner_path(@partner), notice: t("agents.partners.hours_updated")
    end

    private

    def set_partner
      @partner = Partner.find_by!(slug: params[:id])
    end

    def partner_params
      params.require(:partner).permit(
        :category, :address, :latitude, :longitude, :phone, :website, :published,
        :name_fr, :name_en, :description_fr, :description_en
      )
    end
  end
end
