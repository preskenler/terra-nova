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

    # Compress responses with gzip. Placed at the top of the middleware stack so
    # it also covers the static assets (CSS/JS) served by ActionDispatch::Static
    # before the app. Only text-like payloads are compressed.
    config.middleware.insert_before(
      0, Rack::Deflater,
      if: lambda { |_env, _status, headers, _body|
        headers["content-type"].to_s.match?(%r{\A(?:text/|application/(?:json|xml|javascript)|image/svg)})
      }
    )

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Internationalization: French is the default interface language, English is
    # the fallback. New locales are picked up automatically from config/locales.
    config.i18n.available_locales = %i[fr en es]
    config.i18n.default_locale = :fr
    config.i18n.fallbacks = [ :en ]
  end
end
