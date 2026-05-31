// Entry point for the build script in your package.json
import { Turbo } from "@hotwired/turbo-rails"
import "./controllers"
import "./ga4"

// Turboの確認処理を自前のダイアログに差し替える
Turbo.setConfirmMethod((message) => {
  return new Promise((resolve) => {
    const dialog = document.getElementById("turbo-confirm")
    dialog.querySelector("p").textContent = message
    dialog.showModal()

    dialog.addEventListener("close", () => {
      resolve(dialog.returnValue === "confirm")
    }, { once: true })
  })
})

// 遷移完了時に閉じる
document.addEventListener("turbo:load", () => {
  document.getElementById("loading-overlay")?.classList.add("hidden")
})

// バリデーションエラーで戻ってきた時にも閉じる
document.addEventListener("turbo:render", () => {
  document.getElementById("loading-overlay")?.classList.add("hidden")
})
