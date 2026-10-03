# frozen_string_literal: true

# A municipal project citizens can consult (F67).
class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :slug, null: false
      t.json   :name_translations
      t.json   :description_translations

      t.string  :category
      t.string  :status, null: false, default: "planned"
      t.date    :starts_on
      t.date    :ends_on
      t.boolean :published, null: false, default: true

      t.timestamps
    end

    add_index :projects, :slug, unique: true
    add_index :projects, :status
  end
end
