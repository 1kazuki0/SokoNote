// Stimulusの読み込み
import { Controller } from "@hotwired/stimulus"

// static targets = […]でJSで操作したいHTMLの要素を定義
export default class extends Controller {

  // HTML側で参照したい要素を定義（商品名・内容量・単価）
  static targets = ["itemName", "contentQuantity", "contentUnit", "message"
  ]

  static values = { url: String }

  async restoreValues() {
    const name = this.itemNameTarget.value
    if (!name) return

    const response = await fetch(`/item_registration/last_purchase?name=${encodeURIComponent(name)}`)
    const data = await response.json()

    let restored = false

    if (data.content_quantity) {
      this.contentQuantityTarget.value = data.content_quantity
      this.highlight(this.contentQuantityTarget)
      restored = true
    }
    if (data.content_unit_name) {
      this.contentUnitTarget.value = data.content_unit_name
      this.highlight(this.contentUnitTarget)
      restored = true
    }

    if (restored) {
      this.showMessage()
    }
  }

  highlight(element) {
    element.classList.add("bg-amber-50", "border-amber-400", "text-amber-900")
  }

  showMessage() {
    this.messageTarget.classList.remove("hidden")
    setTimeout(() => {
      this.messageTarget.classList.add("hidden")
    }, 5000)
  }
}