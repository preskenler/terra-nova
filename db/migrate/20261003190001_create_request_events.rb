# frozen_string_literal: true

class CreateRequestEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :request_events do |t|
      t.references :request, null: false, foreign_key: true

      t.string  :from_status
      t.string  :to_status, null: false
      t.text    :comment
      t.boolean :visible_to_citizen, null: false, default: true

      t.references :created_by, polymorphic: true, null: true

      t.timestamps
    end
  end
end
