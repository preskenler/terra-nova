# frozen_string_literal: true

class CreateRequestSupports < ActiveRecord::Migration[8.1]
  def change
    create_table :request_supports do |t|
      t.references :request, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :request_supports, [ :request_id, :user_id ], unique: true
  end
end
