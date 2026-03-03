// StimulusライブラリからControllerクラスを読み込む
import { Controller } from "@hotwired/stimulus"

// static targets = […]でJSで操作したいHTMLの要素を定義
export default class extends Controller {
  static targets = [
    "contentquantityA", "packquantityA", "priceA", "resultA",
    "contentquantityB", "packquantityB", "priceB", "resultB",
    "compareResultItem"
  ]

  // A・B両方の単価を計算後、比較処理を実行する
  calculate() {
    this.resultA.textContent = this.calcUnitPrice(
      this.contentquantityATarget.value,
      this.packquantityATarget.value,
      this.priceATarget.value
    )
    this.resultB.textContent = this.calcUnitPrice(
      this.contentquantityBTarget.value,
      this.packquantityBTarget.value,
      this.priceBTarget.value
    )
    this.compare()

  }
  // 単価 = 価格 ÷ 内容量 ÷ 個数 で算出
  // 未入力・0の項目がある場合は計算不能のため"---"を返す
  calcUnitPrice(contentquantity, packquantity, price){
    const c = parseFloat(contentquantity)
    const q = parseFloat(packquantity)
    const p = parseFloat(price)

    if (!p || !c || !q) return "---"

    return (p / c / q).toFixed(2)
  }

  // A・Bの単価を比較し差額を表示する
  // 未入力時は結果欄を空にして終了する。
  compare() {
    const a = parseFloat(this.resultATarget.textContent)
    const b = parseFloat(this.resultBTarget.textContent)

    if (isNaN(a) || isNaN(b)) {
        this.compareResultItemTarget.textContent = ""
        return
    }

    if (a < b) {
        this.compareResultItemTarget.textContent = `A商品の方が${(b - a).toFixed(2)}円安い！`
    } else if (b < a) {
        this.compareResultItemTarget.textContent = `B商品の方が${(a - b).toFixed(2)}円安い！`
    } else {
        this.compareResultItemTarget.textContent = "同じ価格！"
    }
}

  // resultATargetをresultAのみの記載にし、可読性をあげる
  get resultA() { return this.resultATarget }
  get resultB() { return this.resultBTarget }    
  get compareResultItem() { return this.compareResultItemTarget }
}
