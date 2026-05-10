// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import "./ga4"

// 遷移完了時に閉じる
document.addEventListener("turbo:load", () => {
  document.getElementById("loading-overlay")?.classList.add("hidden")
})

// バリデーションエラーで戻ってきた時にも閉じる
document.addEventListener("turbo:render", () => {
  document.getElementById("loading-overlay")?.classList.add("hidden")
})
