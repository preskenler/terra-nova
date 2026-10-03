# frozen_string_literal: true

# An idea proposed by a citizen to improve the city (F68).
class CreateIdeas < ActiveRecord::Migration[8.1]
  def change
    create_table :ideas do |t|
      t.references :user, null: false, foreign_key: true

      t.string :reference, null: false
      t.string :title, null: false
      t.text   :description, null: false
      t.string :category
      t.string :status, null: false, default: "submitted"

      t.timestamps
    end

    add_index :ideas, :reference, unique: true
    add_index :ideas, :status
  end
end
