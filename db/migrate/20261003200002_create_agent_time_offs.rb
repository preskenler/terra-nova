# frozen_string_literal: true

class CreateAgentTimeOffs < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_time_offs do |t|
      t.references :agent, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at,   null: false
      t.string   :reason

      t.timestamps
    end

    add_index :agent_time_offs, [ :agent_id, :starts_at ]
  end
end
