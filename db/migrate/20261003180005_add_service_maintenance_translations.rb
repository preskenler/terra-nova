# frozen_string_literal: true

class AddServiceMaintenanceTranslations < ActiveRecord::Migration[8.1]
  def change
    remove_column :services, :maintenance_message, :text
    add_column :services, :maintenance_message_translations, :json
  end
end
