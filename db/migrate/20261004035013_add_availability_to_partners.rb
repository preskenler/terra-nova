class AddAvailabilityToPartners < ActiveRecord::Migration[8.1]
  def change
    add_column :partners, :available, :boolean, default: true, null: false
    add_column :partners, :next_action_translations, :json
  end
end
