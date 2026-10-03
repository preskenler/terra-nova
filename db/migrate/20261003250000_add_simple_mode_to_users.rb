# frozen_string_literal: true

# Simple mode: a lighter, faster rendering of key pages (F62).
class AddSimpleModeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :simple_mode, :boolean, null: false, default: false
  end
end
