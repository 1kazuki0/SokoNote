# スワイプで編集・削除ボタンを表示するカード（.swipe-card）を操作するヘルパー（JSドライバ用）
module SwipeHelpers
  # カードを左にスワイプして編集・削除ボタンを表示し、削除をクリックする
  # （headless Chromeはホバー非対応のため、スマホと同じくタッチイベントでスワイプを再現する）
  def swipe_and_click_delete(card)
    page.execute_script(<<~JS, card)
      const card = arguments[0];
      const touch = (x) => new Touch({ identifier: 1, target: card, clientX: x, clientY: 10 });
      card.dispatchEvent(new TouchEvent("touchstart", { touches: [touch(300)], changedTouches: [touch(300)], bubbles: true }));
      card.dispatchEvent(new TouchEvent("touchend", { touches: [], changedTouches: [touch(200)], bubbles: true }));
    JS
    within(card) { click_link "削除" }
  end
end

RSpec.configure do |config|
  config.include SwipeHelpers, type: :system
end
