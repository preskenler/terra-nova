# frozen_string_literal: true

# Request priority (F80) and indexes that keep lists fast under load (F77/F78).
class AddPriorityAndPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    add_column :requests, :priority, :string, null: false, default: "normal"
    add_index :requests, :priority
    add_index :requests, [ :user_id, :status ]

    add_index :demands, :last_seen_at
    add_index :notifications, [ :user_id, :read_at ]
  end
end
