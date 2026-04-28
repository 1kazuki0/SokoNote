import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  press() {
    this.element.classList.add('translate-y-px', 'shadow-sm')
    this.element.classList.remove('shadow-md')
  }

  release() {
    this.element.classList.remove('translate-y-px', 'shadow-sm')
    this.element.classList.add('shadow-md')
  }
}