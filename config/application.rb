require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TerraNova
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # A wrong `RAILS_MASTER_KEY` makes Rails abort the whole boot the first time
    # it reads encrypted credentials (Active Record Encryption reads them during
    # initialization even when the app uses no encrypted attribute). On shared
    # hosting this surfaces only as a bare Apache "500 / ErrorDocument" page.
    #
    # If the key cannot decrypt config/credentials.yml.enc, degrade to running
    # without encrypted credentials instead of refusing to boot — but only when
    # `SECRET_KEY_BASE` is set, so sessions keep working. Otherwise leave the key
    # in place and log an actionable message. Development can derive a local
    # secret from tmp/local_secret.txt, so this only guards production. See DEPLOY.md.
    config.before_configuration do
      next unless Rails.env.production?

      credentials_path = File.expand_path("credentials.yml.enc", __dir__)
      key_path = File.expand_path("master.key", __dir__)
      env_key = ENV["RAILS_MASTER_KEY"].presence

      # No key at all: credentials are simply unavailable. This is fine as long
      # as `SECRET_KEY_BASE` provides the session secret.
      unless env_key || File.exist?(key_path)
        if ENV["SECRET_KEY_BASE"].blank?
          warn "[deploy] Neither RAILS_MASTER_KEY/config/master.key nor SECRET_KEY_BASE is " \
               "set, so secret_key_base cannot be derived and the application will not boot. " \
               "Set one in the application environment, then restart."
        end
        next
      end

      credentials_readable =
        begin
          ActiveSupport::EncryptedConfiguration.new(
            config_path: credentials_path,
            key_path: key_path,
            env_key: "RAILS_MASTER_KEY",
            raise_if_missing_key: true
          ).read
          true
        rescue StandardError
          false
        end

      next if credentials_readable

      if ENV["SECRET_KEY_BASE"].present?
        warn "[deploy] RAILS_MASTER_KEY does not decrypt config/credentials.yml.enc — " \
             "continuing without encrypted credentials because SECRET_KEY_BASE is set."
        ENV.delete("RAILS_MASTER_KEY") if env_key
      else
        warn "[deploy] RAILS_MASTER_KEY does not decrypt config/credentials.yml.enc and " \
             "SECRET_KEY_BASE is not set. Set a valid RAILS_MASTER_KEY (or SECRET_KEY_BASE) " \
             "in the application environment, then restart."
      end
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Internationalization: French is the default interface language, English is
    # the fallback. New locales are picked up automatically from config/locales.
    config.i18n.available_locales = %i[fr en]
    config.i18n.default_locale = :fr
    config.i18n.fallbacks = [ :en ]
  end
end
