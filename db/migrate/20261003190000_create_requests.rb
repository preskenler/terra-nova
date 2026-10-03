# frozen_string_literal: true

class CreateRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :service, null: true, foreign_key: true

      t.string :reference, null: false
      t.string :subject, null: false
      t.text   :description, null: false

      t.string  :location_text
      t.decimal :latitude,  precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.string :status, null: false, default: "submitted"

      t.timestamps
    end

    add_index :requests, :reference, unique: true
    add_index :requests, :status
  end
end
