# frozen_string_literal: true

# Store the attribute-level diff of each audited change so the agent audit log
# can show exactly what changed (F48).
class AddObjectChangesToVersions < ActiveRecord::Migration[8.1]
  def change
    add_column :versions, :object_changes, :text
  end
end
