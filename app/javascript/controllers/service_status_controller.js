import { Controller } from "@hotwired/stimulus"

// Shows the availability of the selected service in the request form, so the
// citizen knows before starting whether the service is open, under maintenance
// or closed (F64).
export default class extends Controller {
  static targets = ["select", "message"]
  static values = { warning: String }

  connect() {
    this.update()
  }

  update() {
    const option = this.selectTarget.selectedOptions[0]
    const status = option?.dataset.status
    const label = option?.dataset.statusLabel

    if (!status || status === "active") {
      this.messageTarget.textContent = ""
      return
    }

    this.messageTarget.textContent = `${label} — ${this.warningValue}`
    this.messageTarget.classList.toggle("text-warning", status === "maintenance")
    this.messageTarget.classList.toggle("text-base-content/60", status !== "maintenance")
  }
}
