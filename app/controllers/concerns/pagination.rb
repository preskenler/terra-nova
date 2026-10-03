# frozen_string_literal: true

# Lightweight pagination for large lists, keeping pages fast and bounded under
# load (F77/F78). No external dependency.
module Pagination
  extend ActiveSupport::Concern

  PER_PAGE = 25

  private

  # Returns a limited/offset scope and sets @page, @pages and @total for the view.
  def paginate(scope)
    @total = scope.count
    @pages = [ (@total.to_f / PER_PAGE).ceil, 1 ].max
    @page = params[:page].to_i
    @page = 1 if @page < 1
    @page = @pages if @page > @pages
    scope.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
  end
end
