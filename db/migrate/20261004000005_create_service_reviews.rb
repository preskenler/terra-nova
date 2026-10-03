# frozen_string_literal: true

# A citizen's comment/rating after using a service (F76).
class CreateServiceReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :service_reviews do |t|
      t.references :service, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.integer :rating
      t.text    :comment
      t.string  :reference, null: false
      t.string  :status, null: false, default: "published"

      t.timestamps
    end

    add_index :service_reviews, :reference, unique: true
    add_index :service_reviews, :status
  end
end
