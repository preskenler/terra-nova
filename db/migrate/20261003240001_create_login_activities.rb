# frozen_string_literal: true

# Records sign-ins so a new device can be detected and reported (F54).
class CreateLoginActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :login_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip
      t.string :user_agent, limit: 255
      t.string :fingerprint, limit: 64

      t.timestamps
    end

    add_index :login_activities, [ :user_id, :fingerprint ]
    add_index :login_activities, :created_at
  end
end
