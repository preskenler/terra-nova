# frozen_string_literal: true

class CreateDemands < ActiveRecord::Migration[8.1]
  def change
    create_table :demands do |t|
      t.string  :request_code, null: false
      t.integer :external_id

      t.string  :requester_name
      t.string  :requester_type
      t.text    :message_public

      t.string  :difficulty
      t.integer :difficulty_level

      t.integer :xp_base
      t.integer :xp_time_bonus
      t.integer :xp_total
      t.integer :xp_available

      t.boolean :is_initial, default: false, null: false
      t.integer :visible_since_wave
      t.string  :arrival_type
      t.integer :wave_number
      t.string  :arrival_time

      t.boolean :is_ai_related, default: false, null: false
      t.boolean :is_ai_request, default: false, null: false
      t.string  :group_name
      t.integer :sort_order

      # Internal triage (agents working the competition backlog)
      t.string  :triage_status, null: false, default: "unseen"
      t.text    :notes
      t.references :assignee, null: true, foreign_key: { to_table: :agents }

      t.datetime :first_seen_at
      t.datetime :last_seen_at
      t.json     :raw_payload

      t.timestamps
    end

    add_index :demands, :request_code, unique: true
    add_index :demands, :triage_status
    add_index :demands, :wave_number
    add_index :demands, :difficulty_level
  end
end
