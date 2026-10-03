# frozen_string_literal: true

# Passwordless sign-in (D02), two-factor authentication (F53), low-data mode
# (F59) and notification on new-device sign-in (F54).
class AddSecurityColumnsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :magic_link_nonce, :string
    add_column :users, :magic_link_sent_at, :datetime

    add_column :users, :otp_secret, :string
    add_column :users, :otp_required, :boolean, null: false, default: false
    add_column :users, :otp_confirmed_at, :datetime

    add_column :users, :reduced_data, :boolean, null: false, default: false
  end
end
