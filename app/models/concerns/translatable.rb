# frozen_string_literal: true

# Lightweight JSON-backed translations (F27).
#
# Declares translated attributes stored in `<attribute>_translations` JSON
# columns. Reading/writing the bare attribute uses the current locale with a
# fallback to the default locale. Per-locale accessors (`name_fr`, `name_en`, …)
# are generated for every available locale so forms and seeds can edit each
# language explicitly.
module Translatable
  extend ActiveSupport::Concern

  class_methods do
    def translates(*attributes)
      attributes.each do |attribute|
        define_method(attribute) do
          translations = public_send("#{attribute}_translations") || {}
          translations[I18n.locale.to_s].presence ||
            translations[I18n.default_locale.to_s]
        end

        define_method("#{attribute}=") do |value|
          translations = (public_send("#{attribute}_translations") || {}).dup
          translations[I18n.locale.to_s] = value
          public_send("#{attribute}_translations=", translations)
        end

        I18n.available_locales.each do |locale|
          define_method("#{attribute}_#{locale}") do
            (public_send("#{attribute}_translations") || {})[locale.to_s]
          end

          define_method("#{attribute}_#{locale}=") do |value|
            translations = (public_send("#{attribute}_translations") || {}).dup
            translations[locale.to_s] = value
            public_send("#{attribute}_translations=", translations)
          end
        end
      end
    end
  end
end
