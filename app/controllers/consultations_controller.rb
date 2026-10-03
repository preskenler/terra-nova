# frozen_string_literal: true

class ConsultationsController < ApplicationController
  def show
    @consultation = Consultation.published.find(params[:id])
    @response = current_user ? @consultation.response_from(current_user) : nil
  end
end
