# frozen_string_literal: true

class CreateDemandSyncs < ActiveRecord::Migration[8.1]
  def change
    create_table :demand_syncs do |t|
      t.datetime :fetched_at, null: false
      t.boolean  :success, null: false, default: false
      t.integer  :http_status
      t.text     :error

      # session block snapshot
      t.string  :status
      t.boolean :is_running
      t.integer :current_wave
      t.integer :elapsed_minutes
      t.integer :visible_requests_count
      t.integer :initial_requests_count
      t.integer :wave_requests_count
      t.integer :next_wave_number
      t.integer :minutes_until_next_wave

      t.json    :raw_session

      t.timestamps
    end

    add_index :demand_syncs, :fetched_at
    add_index :demand_syncs, :success
  end
end
