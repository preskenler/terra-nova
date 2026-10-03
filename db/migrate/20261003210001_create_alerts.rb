# frozen_string_literal: true

class CreateAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :alerts do |t|
      t.json :title_translations
      t.json :body_translations
      t.string :kind, null: false, default: "other"
      t.string :severity, null: false, default: "alert"
      t.string :target_segment, null: false, default: "all"
      t.string :locality

      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.decimal :radius_km, precision: 8, scale: 2

      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :alerts, :active
    add_index :alerts, :kind
  end
end
