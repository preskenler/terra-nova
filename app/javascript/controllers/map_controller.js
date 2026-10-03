import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

// Renders a lightweight OpenStreetMap (Leaflet) map. The map is a progressive
// enhancement: the address and coordinates remain available as text, and the
// container exposes an accessible label (F45/F46).
export default class extends Controller {
  static values = {
    lat: Number,
    lng: Number,
    zoom: { type: Number, default: 15 },
    label: String
  }
  static targets = ["container"]

  connect() {
    if (!this.hasContainerTarget) return

    const center = [this.latValue, this.lngValue]
    this.map = L.map(this.containerTarget, {
      scrollWheelZoom: false
    }).setView(center, this.zoomValue)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: '&copy; OpenStreetMap'
    }).addTo(this.map)

    this.marker = L.marker(center, { icon: this.pinIcon(), title: this.labelValue, alt: this.labelValue })
      .addTo(this.map)
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  // Use a div icon so no marker image assets are required (CSP-friendly).
  pinIcon() {
    return L.divIcon({
      className: "nova-map-pin",
      html: '<span aria-hidden="true">&#128205;</span>',
      iconSize: [28, 28],
      iconAnchor: [14, 28]
    })
  }
}
