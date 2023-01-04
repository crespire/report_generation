import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-display"
export default class extends Controller {
  static targets = ['input'];

  disable() {
    this.element.style.display = 'none';
    let newP = document.createElement('p');
    newP.innerHTML = '<strong>Please wait, your file is being generated for download...</strong>';
    this.element.after(newP);
  }

  hide() {
    this.element.remove();
  }

  message() {
    if (this.inputTarget.value == 'pdf') {
      this.element.lastElementChild.disabled = true;
      this.element.submit();
      this.element.lastElementChild.value = 'Submitting...';
      let newP = document.createElement('p');
      newP.innerHTML = 'Loading client data, please wait...';
      this.element.after(newP);
    }    
  }
}