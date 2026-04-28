// Stimulusの読み込み
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // innerとactionsをtarget名に宣言
  static targets = ["inner", "actions"]

  // タッチデバイス以外は何もしない
  connect() {
    if (!window.matchMedia('(hover: none)').matches) return
    this.startX = 0
    this.swiped = false
  }

  touchstart(e) {
    this.startX = e.touches[0].clientX
  }

  touchend(e) {
    const diff = this.startX - e.changedTouches[0].clientX
    if (diff > 30)                { this.closeOthers(); this.open() }
    else if (diff < -20)          { this.close() }
    else if (Math.abs(diff) < 10) { this.swiped ? this.close() : (this.closeOthers(), this.open()) }
  }

  open() {
    this.innerTarget.style.transform   = 'translateX(-88px)'
    this.actionsTarget.style.transform = 'translateX(0px)'
    this.swiped = true
  }

  close() {
    this.innerTarget.style.transform   = 'translateX(0px)'
    this.actionsTarget.style.transform = 'translateX(100%)'
    this.swiped = false
  }

  // 自分以外を閉じる（closeAll → closeOthersに変更）
  closeOthers() {
    this.application.controllers
      .filter(c => c.identifier === 'swipe' && c !== this)
      .forEach(c => c.close())
  }

  outsideClick(e) {
    if (!this.element.contains(e.target)) this.close()
  }
  
  stopPropagation(e) {
    e.stopPropagation()
  }
}