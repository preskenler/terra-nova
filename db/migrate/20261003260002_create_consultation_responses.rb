# frozen_string_literal: true

# A citizen's recorded answer to a consultation (F65/F66).
class CreateConsultationResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :consultation_responses do |t|
      t.references :consultation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.string :choice, null: false
      t.text   :comment
      t.string :reference, null: false

      t.timestamps
    end

    add_index :consultation_responses, :reference, unique: true
    add_index :consultation_responses, [ :consultation_id, :user_id ],
              unique: true, name: "index_consultation_responses_on_consultation_and_user"
  end
end
