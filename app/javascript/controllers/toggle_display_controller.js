import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-display"
export default class extends Controller {
  disable() {
    this.element.style.display = 'none';
    let newP = document.createElement('p');
    newP.innerHTML = '<strong>Please wait, your file is being generated for download...</strong>';
    this.element.after(newP);
  }

  hide() {
    this.element.remove();
  }
}