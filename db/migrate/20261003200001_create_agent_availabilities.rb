# frozen_string_literal: true

class CreateAgentAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_availabilities do |t|
      t.references :agent, null: false, foreign_key: true
      t.integer :wday, null: false
      t.time    :start_time, null: false
      t.time    :end_time,   null: false
      t.integer :slot_minutes, null: false, default: 30
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
