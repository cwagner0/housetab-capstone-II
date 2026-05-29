import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["total", "includePayer", "debtor", "preview"]

  connect() {
    this.recalculate()
  }

  recalculate() {
    const total = parseFloat(this.totalTarget.value) || 0
    const includePayer = this.includePayerTarget.checked
    const checkedDebtors = this.debtorTargets.filter(c => c.checked).length

    const divisor = checkedDebtors + (includePayer ? 1 : 0)

    if (divisor === 0) {
      this.previewTarget.textContent = "Pick at least one person to split with."
      return
    }
    if (total === 0) {
      this.previewTarget.textContent = `Enter a total to see per-person amounts.`
      return
    }

    const perPerson = Math.floor((total / divisor) * 100) / 100
    const label = divisor === 1 ? "person" : "people"
    this.previewTarget.textContent = `${divisor} ${label} × $${perPerson.toFixed(2)} each`
  }
}
