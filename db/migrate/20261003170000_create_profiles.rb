# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.string :address
      t.string :postal_code
      t.string :city
      t.string :phone
      t.json   :preferences

      t.timestamps
    end
  end
end
