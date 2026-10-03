# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Leaflet CSS lives outside app/assets so it is NOT pulled into the global
# `stylesheet_link_tag :app` bundle; pages that render a map load it explicitly
# (F61: keep non-map pages lighter).
Rails.application.config.assets.paths << Rails.root.join("vendor/assets/stylesheets")
