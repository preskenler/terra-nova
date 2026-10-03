import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

// Renders a Leaflet/OpenStreetMap map (F45/F46). Progressive enhancement: the
// address text and latitude/longitude fields remain usable without JS.
//
// - Read-only mode: set lat/lng/label values on the element.
// - Interactive mode (`data-map-interactive-value="true"`): clicking the map
//   updates the lat/lng input targets and the live coordinate text target.
export default class extends Controller {
  static values = {
    lat: Number,
    lng: Number,
    zoom: { type: Number, default: 14 },
    label: String,
    interactive: { type: Boolean, default: false }
  }
  static targets = ["container", "latInput", "lngInput", "coords"]

  // Fallback centre (downtown Nova Terra) when no coordinates are provided.
  static DEFAULT_CENTER = [ 48.8566, 2.3522 ]

  connect() {
    if (!this.hasContainerTarget) return

    const center = this.hasCoordinates ? [ this.latValue, this.lngValue ] : this.constructor.DEFAULT_CENTER

    this.map = L.map(this.containerTarget, { scrollWheelZoom: false }).setView(center, this.zoomValue)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(this.map)

    if (this.hasCoordinates) {
      this.placeMarker(center)
    }

    if (this.interactiveValue) {
      this.map.on("click", (event) => this.setPoint(event.latlng))
    }
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  setPoint(latlng) {
    this.placeMarker([ latlng.lat, latlng.lng ])
    if (this.hasLatInputTarget) this.latInputTarget.value = latlng.lat.toFixed(6)
    if (this.hasLngInputTarget) this.lngInputTarget.value = latlng.lng.toFixed(6)
    if (this.hasCoordsTarget) {
      this.coordsTarget.textContent = `${latlng.lat.toFixed(5)}, ${latlng.lng.toFixed(5)}`
    }
  }

  placeMarker(center) {
    const options = { icon: this.pinIcon(), title: this.labelValue, alt: this.labelValue }
    if (this.marker) {
      this.marker.setLatLng(center)
    } else {
      this.marker = L.marker(center, options).addTo(this.map)
    }
  }

  get hasCoordinates() {
    return !Number.isNaN(this.latValue) && !Number.isNaN(this.lngValue) &&
      this.latValue !== 0 && this.lngValue !== 0
  }

  // Use a div icon so no marker image assets are required (CSP-friendly).
  pinIcon() {
    return L.divIcon({
      className: "nova-map-pin",
      html: '<span aria-hidden="true">&#128205;</span>',
      iconSize: [ 28, 28 ],
      iconAnchor: [ 14, 28 ]
    })
  }
}
