import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lightIcon", "darkIcon"]

  connect() {
    this.applyTheme()

    // Listen for system preference changes
    window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", () => {
      if (!this.hasStoredPreference()) {
        this.applyTheme()
      }
    })
  }

  toggle() {
    const currentTheme = this.getCurrentTheme()
    const newTheme = currentTheme === "dark" ? "light" : "dark"

    localStorage.setItem("theme", newTheme)
    this.applyTheme()
  }

  applyTheme() {
    const theme = this.getCurrentTheme()

    if (theme === "dark") {
      document.documentElement.classList.add("dark")
      document.documentElement.classList.remove("light")
    } else {
      document.documentElement.classList.add("light")
      document.documentElement.classList.remove("dark")
    }

    this.updateIcons(theme)
  }

  getCurrentTheme() {
    const stored = localStorage.getItem("theme")

    if (stored) {
      return stored
    }

    // Fall back to system preference
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  hasStoredPreference() {
    return localStorage.getItem("theme") !== null
  }

  updateIcons(theme) {
    if (!this.hasLightIconTarget || !this.hasDarkIconTarget) return

    if (theme === "dark") {
      this.lightIconTarget.classList.remove("hidden")
      this.darkIconTarget.classList.add("hidden")
    } else {
      this.lightIconTarget.classList.add("hidden")
      this.darkIconTarget.classList.remove("hidden")
    }
  }
}
