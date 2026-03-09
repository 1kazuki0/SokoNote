// StimulusライブラリからControllerクラスを読み込む
import { Controller } from "@hotwired/stimulus"

// static targets = […]でJSで操作したいHTMLの要素を定義
export default class extends Controller {

// 画面読み込み時、JS実行（購入履歴からのデータ取得時をフォームに自動出力した際にJSが走らないため） 
  connect() {
    this.calculate()
  }

  static targets = [
    "contentquantityA", "packquantityA", "priceA", "taxrateA", "resultA",
    "contentquantityB", "packquantityB", "priceB", "taxrateB", "resultB",
    "compareResultItem",
    "cardA", "cardB", "badgeA", "badgeB"
  ]

  // A・B両方の単価を計算後、比較処理を実行する
  calculate() {
    const taxrateA = this.element.querySelector('input[name="purchase_a[tax_rate]"]:checked')?.value ?? 0
    const taxrateB = this.element.querySelector('input[name="purchase_b[tax_rate]"]:checked')?.value ?? 0
    
    this.resultA.textContent = this.calcUnitPrice(
      this.contentquantityATarget.value,
      this.packquantityATarget.value,
      this.priceATarget.value,
      taxrateA
    )
    this.resultB.textContent = this.calcUnitPrice(
      this.contentquantityBTarget.value,
      this.packquantityBTarget.value,
      this.priceBTarget.value,
      taxrateB
    )
    this.compare()

  }
  // 単価 = 価格 ÷ 内容量 ÷ 個数 で算出
  // 未入力・0の項目がある場合は計算不能のため"---"を返す
  calcUnitPrice(contentquantity, packquantity, price, taxrate){
    const c = parseFloat(contentquantity)
    const q = parseFloat(packquantity)
    const p = parseFloat(price)
    const t = parseFloat(taxrate)

    if (!p || !c || !q || isNaN(t)) return "---"

    return (p / (1 + t / 100) / c / q).toFixed(2)
  }

  // A・Bの単価を比較し差額を表示する
  // 未入力時は結果欄を空にして終了する。
  compare() {
    const a = parseFloat(this.resultATarget.textContent)
    const b = parseFloat(this.resultBTarget.textContent)

    this.cardATarget.classList.remove("border-green", "border-2", "shadow-lg")
    this.cardBTarget.classList.remove("border-green", "border-2", "shadow-lg")
    this.badgeATarget.classList.add("invisible")
    this.badgeBTarget.classList.add("invisible")

    if (isNaN(a) || isNaN(b)) {
        this.compareResultItemTarget.textContent = ""
        this.compareResultItemTarget.classList.add("invisible")
        return
    }

    if (a < b) {
        this.compareResultItemTarget.textContent = `A商品の方が${(b - a).toFixed(2)}円安い！`
        this.cardATarget.classList.add("border-green", "border-2", "shadow-lg")
        this.badgeATarget.classList.remove("invisible")
        this.compareResultItemTarget.classList.remove("invisible")
    } else if (b < a) {
        this.compareResultItemTarget.textContent = `B商品の方が${(a - b).toFixed(2)}円安い！`
        this.cardBTarget.classList.add("border-green", "border-2", "shadow-lg")
        this.badgeBTarget.classList.remove("invisible")
        this.compareResultItemTarget.classList.remove("invisible")
    } else {
        this.compareResultItemTarget.textContent = "同じ価格！"
        this.compareResultItemTarget.classList.remove("invisible")
    }
}

  // resultATargetをresultAのみの記載にし、可読性をあげる
  get resultA() { return this.resultATarget }
  get resultB() { return this.resultBTarget }    
  get compareResultItem() { return this.compareResultItemTarget }
}
