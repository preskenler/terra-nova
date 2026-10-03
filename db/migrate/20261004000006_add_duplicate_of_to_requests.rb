# frozen_string_literal: true

# Let agents link a request to the request it duplicates (F75).
class AddDuplicateOfToRequests < ActiveRecord::Migration[8.1]
  def change
    add_reference :requests, :duplicate_of, null: true, foreign_key: { to_table: :requests }
  end
end
