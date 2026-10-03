# frozen_string_literal: true

class PartnersController < ApplicationController
  def index
    @partners = Partner.published.ordered.to_a
  end

  def show
    @partner = Partner.published.find_by!(slug: params[:id])
  end
end
