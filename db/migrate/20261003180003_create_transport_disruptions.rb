# frozen_string_literal: true

class CreateTransportDisruptions < ActiveRecord::Migration[8.1]
  def change
    create_table :transport_disruptions do |t|
      t.references :transport_line, null: false, foreign_key: true
      t.json :message_translations
      t.string :severity, null: false, default: "info"
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
