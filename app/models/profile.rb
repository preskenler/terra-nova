# frozen_string_literal: true

# Extra information attached to a citizen account (D01/D03).
class Profile < ApplicationRecord
  has_paper_trail ignore: %i[updated_at]

  belongs_to :user

  validates :phone, format: { with: /\A[0-9 +().-]{6,20}\z/, allow_blank: true }
end
