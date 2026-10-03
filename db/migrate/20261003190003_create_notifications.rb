# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :notifiable, polymorphic: true, null: true

      t.string   :kind, null: false, default: "general"
      t.string   :title, null: false
      t.text     :body
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, :read_at
  end
end
