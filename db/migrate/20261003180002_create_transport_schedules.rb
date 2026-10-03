# frozen_string_literal: true

class CreateTransportSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :transport_schedules do |t|
      t.references :transport_line, null: false, foreign_key: true
      t.integer :wday, null: false
      t.string  :first_departure
      t.string  :last_departure
      t.integer :frequency_minutes
      t.timestamps
    end
  end
end
