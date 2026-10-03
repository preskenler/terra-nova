# frozen_string_literal: true

module Agents
  # Read-only audit trail view over PaperTrail versions (F47/F48).
  class AuditLogsController < BaseController
    include Pagination

    def index
      authorize :audit_log, :index?

      scope = PaperTrail::Version.order(created_at: :desc)
      scope = scope.where(item_type: params[:item_type]) if params[:item_type].present?
      scope = scope.where(event: params[:event]) if params[:event].present?
      scope = scope.where(whodunnit: params[:actor]) if params[:actor].present?

      if params[:q].present?
        query = "%#{params[:q].strip}%"
        scope = scope.where("item_type ILIKE :q OR item_id::text ILIKE :q", q: query)
      end

      @versions = paginate(scope).to_a
      @item_types = PaperTrail::Version.distinct.order(:item_type).pluck(:item_type)
      @events = PaperTrail::Version.distinct.order(:event).pluck(:event)
    end

    def show
      authorize :audit_log, :show?
      @version = PaperTrail::Version.find(params[:id])
      @changes = @version.changeset
    end
  end
end
