# frozen_string_literal: true

# Direct replies from agents to a citizen's request (F84). Kept separate from
# RequestEvent so the agent can post a threaded reply without changing status.
class CreateRequestReplies < ActiveRecord::Migration[8.1]
  def change
    create_table :request_replies do |t|
      t.references :request, null: false, foreign_key: true
      t.references :created_by, polymorphic: true
      t.text :body, null: false
      t.boolean :internal, null: false, default: false
      t.timestamps
    end
  end
end
