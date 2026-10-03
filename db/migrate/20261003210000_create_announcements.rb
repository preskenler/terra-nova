# frozen_string_literal: true

class CreateAnnouncements < ActiveRecord::Migration[8.1]
  def change
    create_table :announcements do |t|
      t.json :title_translations
      t.json :body_translations
      t.string :severity, null: false, default: "info"
      t.string :target_audience, null: false, default: "all"
      t.datetime :published_at
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :announcements, :active
    add_index :announcements, :severity
  end
end
