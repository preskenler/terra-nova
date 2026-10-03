# frozen_string_literal: true

# Sign-in by citizen identifier, so residents without an email can still access
# the platform (F71).
class AddLoginIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :login_id, :string
    add_index :users, :login_id, unique: true
  end
end
