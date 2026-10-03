import { Controller } from "@hotwired/stimulus"

// Periodically asks the server to poll the external Webcup API and streams the
// refreshed console back in, without reloading the page (preserves focus and
// scroll for keyboard/screen-reader users).
export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 30000 }
  }

  connect() {
    this.timer = setInterval(() => this.refresh(), this.intervalValue)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  async refresh() {
    const url = new URL(this.urlValue, window.location.origin)
    // Preserve the active filters.
    url.search = window.location.search

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": this.csrfToken
        },
        credentials: "same-origin"
      })

      if (response.ok) {
        const html = await response.text()
        if (window.Turbo) window.Turbo.renderStreamMessage(html)
      }
    } catch (_error) {
      // Network hiccup: the next tick retries.
    }
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }
}
