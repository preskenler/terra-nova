class AddPlainLanguageTranslationsToServices < ActiveRecord::Migration[8.1]
  def change
    add_column :services, :plain_language_translations, :json
  end
end
