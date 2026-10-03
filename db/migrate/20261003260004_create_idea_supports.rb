# frozen_string_literal: true

# A citizen supporting another citizen's idea (F68).
class CreateIdeaSupports < ActiveRecord::Migration[8.1]
  def change
    create_table :idea_supports do |t|
      t.references :idea, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :idea_supports, [ :idea_id, :user_id ], unique: true
  end
end
