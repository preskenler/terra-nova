# frozen_string_literal: true

# A consultation asking citizens for their opinion (F65/F66).
class CreateConsultations < ActiveRecord::Migration[8.1]
  def change
    create_table :consultations do |t|
      t.references :project, null: true, foreign_key: true

      t.json :title_translations
      t.json :description_translations

      t.string   :kind, null: false, default: "opinion"
      t.string   :status, null: false, default: "draft"
      t.datetime :opens_at
      t.datetime :closes_at

      t.timestamps
    end

    add_index :consultations, :status
  end
end
