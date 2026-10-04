class AddReplacementToTransportDisruptions < ActiveRecord::Migration[8.1]
  def change
    add_column :transport_disruptions, :replacement_translations, :json
  end
end
