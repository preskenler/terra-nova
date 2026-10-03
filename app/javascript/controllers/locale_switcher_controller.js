import { Controller } from "@hotwired/stimulus"

// Submits the surrounding form when the language <select> changes.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
