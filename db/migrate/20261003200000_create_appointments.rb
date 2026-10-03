# frozen_string_literal: true

class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :user,  null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.references :service, null: true, foreign_key: true

      t.datetime :starts_at, null: false
      t.datetime :ends_at,   null: false
      t.integer  :duration_minutes, null: false, default: 30

      t.text   :notes
      t.string :status, null: false, default: "confirmed"
      t.string :cancellation_reason
      t.datetime :reminder_sent_at

      t.timestamps
    end

    add_index :appointments, :starts_at
    add_index :appointments, :status
  end
end
