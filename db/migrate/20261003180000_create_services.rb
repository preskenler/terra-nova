# frozen_string_literal: true

class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.string :slug, null: false
      t.json   :name_translations
      t.json   :description_translations

      t.string  :category
      t.boolean :priority,  null: false, default: false
      t.boolean :emergency, null: false, default: false
      t.string  :status,    null: false, default: "active"

      t.string  :address
      t.decimal :latitude,  precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.string :contact_email
      t.string :contact_phone

      t.text   :maintenance_message
      t.string :expected_return

      t.timestamps
    end

    add_index :services, :slug, unique: true
    add_index :services, :category
    add_index :services, :priority
    add_index :services, :status
    add_index :services, :emergency
  end
end
