require 'rails_helper'

RSpec.describe "購入履歴一覧画面", type: :system do
  let(:user) { create(:user) }
  let(:category) { create(:category, name: "飲料", user: user) }
  let(:item) { create(:item, name: "牛乳", category: category, user: user) }
  let(:store_a) { create(:store, name: "スーパーA", user: user) }
  let(:store_b) { create(:store, name: "ドラッグB", user: user) }
  let(:ml) { create(:content_unit, name: "ml", user: user) }
  let(:bottle) { create(:pack_unit, name: "本", user: user) }

  # 単価0.4円（最安値）
  let(:cheapest_purchase) do
    create(:purchase, user: user, item: item, store: store_a, content_unit: ml, pack_unit: bottle, brand: "明治",
                      content_quantity: 500, pack_quantity: 2, price: 432, tax_rate: 8, purchased_on: "2026-09-01")
  end
  # 単価0.6円
  let(:newest_purchase) do
    create(:purchase, user: user, item: item, store: store_b, content_unit: ml, pack_unit: nil, brand: "森永",
                      content_quantity: 1000, pack_quantity: 1, price: 600, tax_rate: 0, purchased_on: "2026-10-01")
  end
  # 単価0.7円（店舗・ブランド・単位（包装数）なし）
  let(:oldest_purchase) do
    create(:purchase, :only_required_purchase, user: user, item: item, content_unit: ml,
                      content_quantity: 500, pack_quantity: 3, price: 1155, tax_rate: 10, purchased_on: "2026-08-01")
  end

  # JSドライバが必要なテスト（js: true）以外はrack_testで実行する
  before do |example|
    driven_by(:rack_test) unless example.metadata[:js]
    sign_in user
  end

  # 購入履歴カードを購入日で特定する
  def purchase_card(purchase)
    find(".swipe-card", text: purchase.purchased_on.strftime("%Y-%m-%d"))
  end

  # 表示されている購入履歴カードの購入日を、表示順に取得する
  def displayed_dates
    all(".swipe-card").map { |card| card.text[/\d{4}-\d{2}-\d{2}/] }
  end

  # 購入履歴カードを左にスワイプして編集・削除ボタンを表示し、削除をクリックする
  # （headless Chromeはホバー非対応のため、スマホと同じくタッチイベントでスワイプを再現する）
  def swipe_and_click_delete(purchase)
    card = purchase_card(purchase)
    page.execute_script(<<~JS, card)
      const card = arguments[0];
      const touch = (x) => new Touch({ identifier: 1, target: card, clientX: x, clientY: 10 });
      card.dispatchEvent(new TouchEvent("touchstart", { touches: [touch(300)], changedTouches: [touch(300)], bubbles: true }));
      card.dispatchEvent(new TouchEvent("touchend", { touches: [], changedTouches: [touch(200)], bubbles: true }));
    JS
    within(card) { click_link "削除" }
  end

  describe "購入履歴がある場合" do
    before do
      cheapest_purchase
      newest_purchase
      oldest_purchase
    end

    describe "画面表示" do
      before { visit item_purchases_path(item) }

      it "商品名とカテゴリーが表示される" do
        expect(page).to have_content("牛乳 購入履歴")
        expect(page).to have_css("span", text: "飲料")
      end

      it "最安値の購入履歴の情報が表示される" do
        expect(page).to have_content("現在最安値")
        expect(page).to have_content("1mlあたり")
        expect(page).to have_content("0.4 円")
        expect(page).to have_content("500.0ml × 2本")
        expect(page).to have_content("¥432")
        expect(page).to have_content("(税込8%)")
        expect(page).to have_content("スーパーA")
        expect(page).to have_content("明治")
      end

      it "「この商品で比較する」リンクに最安値の購入履歴が指定されている" do
        expect(page).to have_link("この商品で比較する", href: comparison_path(purchase_id: cheapest_purchase.id))
      end

      it "購入履歴が購入日の新しい順に表示される" do
        expect(displayed_dates).to eq [ "2026-10-01", "2026-09-01", "2026-08-01" ]
      end

      it "購入履歴カードに購入日・店舗・ブランド・内容量・価格・単価が表示される" do
        within(purchase_card(newest_purchase)) do
          expect(page).to have_content("ドラッグB")
          expect(page).to have_content("森永")
          expect(page).to have_content("1000.0ml")
          expect(page).to have_content("¥600")
          expect(page).to have_content("(税抜)")
          expect(page).to have_content("0.6 円/ml")
        end
      end

      it "単位（包装数）がなく包装数が2以上の場合、包装数のみが表示される" do
        within(purchase_card(oldest_purchase)) do
          expect(page).to have_content("500.0ml × 3")
          expect(page).to have_content("(税込10%)")
        end
      end

      it "最安値の購入履歴のみ強調表示される" do
        expect(page).to have_css(".swipe-card.border-accent", count: 1)
        expect(page).to have_css(".swipe-card.border-accent", text: "2026-09-01")
      end

      it "店舗名の入力候補に購入履歴の店舗が含まれる" do
        expect(page).to have_css("datalist#stores_list option[value='スーパーA']", visible: false)
        expect(page).to have_css("datalist#stores_list option[value='ドラッグB']", visible: false)
      end
    end

    describe "並び替え" do
      before { visit item_purchases_path(item) }

      it "「単価」で単価の安い順に並び替えられる" do
        click_link "単価"
        expect(displayed_dates).to eq [ "2026-09-01", "2026-10-01", "2026-08-01" ]
      end

      it "「購入日」で購入日の古い順に並び替えられる" do
        click_link "購入日"
        expect(displayed_dates).to eq [ "2026-08-01", "2026-09-01", "2026-10-01" ]
      end
    end

    describe "店舗名での絞り込み" do
      before { visit item_purchases_path(item) }

      it "店舗名の一部で絞り込める" do
        fill_in "q[store_name_cont]", with: "スーパー\n"
        expect(displayed_dates).to eq [ "2026-09-01" ]
      end

      context "該当する購入履歴がない場合" do
        before { fill_in "q[store_name_cont]", with: "コンビニ\n" }

        it "見つからなかったメッセージが表示される" do
          expect(page).to have_content("検索した結果、見つかりませんでした")
          expect(page).to have_link("商品を登録する", href: new_item_registration_path)
        end

        it "「検索条件をリセット」で全ての購入履歴が表示される" do
          click_link "検索条件をリセット"
          expect(page).to have_current_path(item_purchases_path(item))
          expect(displayed_dates.size).to eq 3
        end
      end
    end

    describe "画面遷移" do
      before { visit item_purchases_path(item) }

      it "「編集」から購入履歴編集画面に遷移できる" do
        within(purchase_card(newest_purchase)) do
          click_link "編集"
        end
        expect(page).to have_current_path(edit_item_purchase_path(item, newest_purchase))
      end

      it "「この商品で比較する」から比較画面に遷移できる" do
        click_link "この商品で比較する"
        expect(page).to have_current_path(comparison_path(purchase_id: cheapest_purchase.id))
      end
    end

    describe "購入履歴の削除", js: true do
      before { visit item_purchases_path(item) }

      it "確認ダイアログで「削除する」を選ぶと削除される" do
        swipe_and_click_delete(newest_purchase)
        within("#turbo-confirm") do
          expect(page).to have_content("本当に削除しますか？")
          click_button "削除する"
        end
        expect(page).to have_content("購入履歴を削除しました")
        expect(page).not_to have_css(".swipe-card", text: "2026-10-01")
        expect(Purchase.exists?(newest_purchase.id)).to be false
      end

      it "確認ダイアログで「キャンセル」を選ぶと削除されない" do
        swipe_and_click_delete(newest_purchase)
        within("#turbo-confirm") { click_button "キャンセル" }
        expect(page).to have_css(".swipe-card", text: "2026-10-01")
        expect(Purchase.exists?(newest_purchase.id)).to be true
      end
    end
  end

  describe "購入履歴の最後の1件を削除した場合", js: true do
    before do
      cheapest_purchase
      visit item_purchases_path(item)
    end

    it "購入履歴がない状態の画面が表示される" do
      swipe_and_click_delete(cheapest_purchase)
      within("#turbo-confirm") { click_button "削除する" }
      expect(page).to have_content("購入履歴を削除しました")
      expect(page).to have_content("購入履歴がありません")
    end
  end

  describe "購入履歴がない場合" do
    before { visit item_purchases_path(item) }

    it "購入履歴がないメッセージと商品名が表示される" do
      expect(page).to have_content("購入履歴がありません")
      expect(page).to have_content("商品名：牛乳")
    end

    it "「購入履歴を登録する」から商品登録画面に遷移できる" do
      click_link "購入履歴を登録する"
      expect(page).to have_current_path(new_item_registration_path)
    end

    it "商品を削除するボタンが表示される" do
      expect(page).to have_button("この商品を削除する")
    end

    context "画面表示後に別の画面で購入履歴が登録された場合" do
      it "商品は削除されず、エラーメッセージが表示される" do
        create(:purchase, user: user, item: item)
        click_button "この商品を削除する"
        expect(page).to have_current_path(item_purchases_path(item))
        expect(page).to have_content("購入履歴がある商品は削除できません")
        expect(Item.exists?(item.id)).to be true
      end
    end
  end

  describe "商品の削除", js: true do
    before { visit item_purchases_path(item) }

    it "確認ダイアログで「削除する」を選ぶと商品が削除され、商品一覧画面に遷移する" do
      click_button "この商品を削除する"
      within("#turbo-confirm") do
        expect(page).to have_content("「牛乳」を本当に削除しますか?")
        click_button "削除する"
      end
      expect(page).to have_content("「牛乳」を削除しました")
      expect(page).to have_current_path(items_path)
      expect(Item.exists?(item.id)).to be false
    end

    it "確認ダイアログで「キャンセル」を選ぶと商品は削除されない" do
      click_button "この商品を削除する"
      within("#turbo-confirm") { click_button "キャンセル" }
      expect(page).to have_current_path(item_purchases_path(item))
      expect(Item.exists?(item.id)).to be true
    end
  end
end
