# frozen_string_literal: true

class CreateTransportLines < ActiveRecord::Migration[8.1]
  def change
    create_table :transport_lines do |t|
      t.string :slug, null: false
      t.json   :name_translations
      t.json   :description_translations
      t.string  :mode, null: false, default: "bus"
      t.string  :color
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :transport_lines, :slug, unique: true
  end
end
