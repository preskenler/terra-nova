# frozen_string_literal: true

# Pin an official message so it is visible site-wide immediately (F73).
class AddPinnedToAnnouncements < ActiveRecord::Migration[8.1]
  def change
    add_column :announcements, :pinned, :boolean, null: false, default: false
    add_index :announcements, :pinned
  end
end
