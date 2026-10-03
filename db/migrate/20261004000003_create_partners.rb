# frozen_string_literal: true

# Partners (associations, businesses) with opening hours and a location (F74).
class CreatePartners < ActiveRecord::Migration[8.1]
  def change
    create_table :partners do |t|
      t.string :slug, null: false
      t.json   :name_translations
      t.json   :description_translations

      t.string  :category
      t.string  :address
      t.decimal :latitude,  precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string  :phone
      t.string  :website
      t.boolean :published, null: false, default: true

      t.timestamps
    end

    add_index :partners, :slug, unique: true
    add_index :partners, :category
  end
end
