# frozen_string_literal: true

class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.references :user, null: true, foreign_key: true

      t.string :kind, null: false, default: "question"
      t.string :email
      t.string :subject, null: false
      t.text   :message, null: false
      t.string :status, null: false, default: "new"
      t.text   :agent_notes
      t.string :reference, null: false

      t.timestamps
    end

    add_index :feedbacks, :reference, unique: true
    add_index :feedbacks, :status
    add_index :feedbacks, :kind
  end
end
