# frozen_string_literal: true

# Security-relevant events for monitoring (F69).
class CreateSecurityEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :security_events do |t|
      t.string :event, null: false
      t.references :actor, polymorphic: true, null: true
      t.string :ip
      t.string :user_agent, limit: 255
      t.json :metadata

      t.timestamps
    end

    add_index :security_events, :event
    add_index :security_events, :created_at
  end
end
