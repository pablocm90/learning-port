import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drip", "moments"]
  static values = { expanded: String }

  connect() {
    this.expandedValue = ""
  }

  toggle(event) {
    const dripId = event.currentTarget.dataset.dripId

    if (this.expandedValue === dripId) {
      this.collapse()
    } else {
      this.expand(dripId)
    }
  }

  expand(dripId) {
    // Collapse any currently expanded drip
    this.collapse()

    // Expand the clicked drip
    this.expandedValue = dripId
    const drip = this.element.querySelector(`[data-drip-id="${dripId}"]`)
    const moments = drip?.querySelector('[data-paint-drip-target="moments"]')

    if (drip && moments) {
      drip.classList.add("expanded")
      moments.classList.remove("hidden")
      moments.classList.add("animate-expand")
    }
  }

  collapse() {
    if (!this.expandedValue) return

    const drip = this.element.querySelector(`[data-drip-id="${this.expandedValue}"]`)
    const moments = drip?.querySelector('[data-paint-drip-target="moments"]')

    if (drip && moments) {
      drip.classList.remove("expanded")
      moments.classList.add("hidden")
      moments.classList.remove("animate-expand")
    }

    this.expandedValue = ""
  }

  closeOnClickOutside(event) {
    if (!this.expandedValue) return

    const expandedDrip = this.element.querySelector(`[data-drip-id="${this.expandedValue}"]`)
    if (expandedDrip && !expandedDrip.contains(event.target)) {
      this.collapse()
    }
  }
}
