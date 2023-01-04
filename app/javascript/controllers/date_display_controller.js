import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="date-display"
export default class extends Controller {
  static targets = ["input", "year", "week"];

  connect() {
    this.toggle();
  }

  toggle() {
    if (this.inputTarget.value == 'pdf') {
      this.yearTarget.hidden = false;
      this.yearTarget.disabled = false;
      this.weekTarget.hidden = true;
      this.weekTarget.disabled = true;
    } else if (this.inputTarget.value == 'xlsx') {
      this.yearTarget.hidden = true;
      this.yearTarget.disabled = true;
      this.weekTarget.hidden = false;
      this.weekTarget.disabled = false;
    }
  }
}