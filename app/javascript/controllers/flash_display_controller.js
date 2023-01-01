import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash-display"
export default class extends Controller {
  hide() {
    this.element.remove();
  }
}