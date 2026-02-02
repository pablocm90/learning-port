import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["moments"]
  static values = { expanded: String }

  connect() {
    this.expandedValue = ""
  }

  toggle(event) {
    // Handle click on SVG group - find the drip-id from the clicked element or its parent
    let target = event.target
    while (target && !target.dataset?.dripId && target !== this.element) {
      target = target.parentElement
    }

    const dripId = target?.dataset?.dripId
    if (!dripId) return

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

    // Find the SVG drip group
    const dripGroup = this.element.querySelector(`g[data-drip-id="${dripId}"]`)

    // Find the corresponding moments panel in the details section
    const detailContainer = this.element.querySelector(`.drip-detail-container[data-drip-id="${dripId}"]`)
    const moments = detailContainer?.querySelector('[data-paint-drip-target="moments"]')

    if (dripGroup) {
      dripGroup.classList.add("expanded")
    }

    if (moments) {
      moments.classList.remove("hidden")
      moments.classList.add("animate-expand")
    }
  }

  collapse() {
    if (!this.expandedValue) return

    const dripGroup = this.element.querySelector(`g[data-drip-id="${this.expandedValue}"]`)
    const detailContainer = this.element.querySelector(`.drip-detail-container[data-drip-id="${this.expandedValue}"]`)
    const moments = detailContainer?.querySelector('[data-paint-drip-target="moments"]')

    if (dripGroup) {
      dripGroup.classList.remove("expanded")
    }

    if (moments) {
      moments.classList.add("hidden")
      moments.classList.remove("animate-expand")
    }

    this.expandedValue = ""
  }

  closeOnClickOutside(event) {
    if (!this.expandedValue) return

    // Check if click is inside any drip group or moments panel
    const dripGroup = this.element.querySelector(`g[data-drip-id="${this.expandedValue}"]`)
    const detailContainer = this.element.querySelector(`.drip-detail-container[data-drip-id="${this.expandedValue}"]`)

    const clickedInDrip = dripGroup?.contains(event.target)
    const clickedInDetails = detailContainer?.contains(event.target)

    if (!clickedInDrip && !clickedInDetails) {
      this.collapse()
    }
  }
}
