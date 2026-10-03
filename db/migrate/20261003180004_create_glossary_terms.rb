# frozen_string_literal: true

class CreateGlossaryTerms < ActiveRecord::Migration[8.1]
  def change
    create_table :glossary_terms do |t|
      t.string :slug, null: false
      t.json   :term_translations
      t.json   :definition_translations
      t.timestamps
    end

    add_index :glossary_terms, :slug, unique: true
  end
end
