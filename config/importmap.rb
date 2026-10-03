# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# Leaflet is imported dynamically by the map controller, so it must NOT be
# module-preloaded on every page (F61). It is fetched only where a map renders.
pin "leaflet", preload: false # @1.9.4
