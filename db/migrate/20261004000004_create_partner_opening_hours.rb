# frozen_string_literal: true

class CreatePartnerOpeningHours < ActiveRecord::Migration[8.1]
  def change
    create_table :partner_opening_hours do |t|
      t.references :partner, null: false, foreign_key: true
      t.integer :wday, null: false
      t.string  :opens_at
      t.string  :closes_at
      t.boolean :closed, null: false, default: false

      t.timestamps
    end

    add_index :partner_opening_hours, [ :partner_id, :wday ], unique: true
  end
end
