require "rails_helper"

RSpec.describe "Purchases", type: :system do
  let(:user)     { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }
  let(:category) { user.categories.create(name: "食品") }
  let(:store)    { user.stores.create(name: "スーパー大阪店") }
  let(:item)     { category.items.create(name: "ハム", user: user) }
  let(:purchase) do
    item.purchases.create(
      brand:            "日本ハム",
      content_quantity: 5,
      content_unit:     "枚",
      pack_quantity:    "3",
      pack_unit:        "パック",
      price:            210,
      unit_price:       14,
      tax_rate:         0,
      purchased_on:     "2026/03/13",
      user:             user,
      store:            store
    )
  end

  before do
    driven_by(:rack_test)
    sign_in user
    visit edit_purchase_path(purchase)
  end

  # ─── 画面の表示 ──────────────────────────────────────────────────────────────
  describe "購入履歴画面の表示" do
    it "タイトルに「商品情報の編集」と表示される" do
      expect(page).to have_content("商品情報の編集")
    end

    it "「商品情報の更新」と表示される" do
      expect(page).to have_content("商品情報の更新")
    end

    it "商品名の入力欄が表示される" do
      expect(page).to have_field("商品名")
    end

    it "カテゴリ名の入力欄が表示される" do
      expect(page).to have_field("カテゴリ")
    end

    it "メーカー名の入力欄が表示される" do
      expect(page).to have_field("メーカー名")
    end

    it "店舗名の入力欄が表示される" do
      expect(page).to have_field("店舗名")
    end

    it "内容量の入力欄が表示される" do
      expect(page).to have_field("内容量")
    end

    it "単位／内容量の入力欄が表示される" do
      expect(page).to have_field("単位（内容量）")
    end

    it "パック数の入力欄が表示される" do
      expect(page).to have_field("パック数")
    end

    it "単位／パック数の入力欄が表示される" do
      expect(page).to have_field("単位（パック数）")
    end

    it "価格の入力欄が表示される" do
      expect(page).to have_field("価格")
    end

    it "税率の選択肢が3つ表示される（税抜・8%・10%）" do
      expect(page).to have_content("税抜")
      expect(page).to have_content("8%")
      expect(page).to have_content("10%")
    end

    it "登録日の入力欄が表示される" do
      expect(page).to have_field("登録日")
    end

    it "「この内容で更新する」ボタンが表示される" do
      expect(page).to have_button("この内容で更新する")
    end
  end

  # ─── 既存データの反映 ─────────────────────────────────────────────────────────
  describe "既存データの反映" do
    it "商品名が入力済みになっている" do
      expect(page).to have_field("商品名", with: "ハム")
    end

    it "カテゴリ名が入力済みになっている" do
      expect(page).to have_field("カテゴリ", with: "食品")
    end

    it "メーカー名が入力済みになっている" do
      expect(page).to have_field("メーカー名", with: "日本ハム")
    end

    it "店舗名が入力済みになっている" do
      expect(page).to have_field("店舗名", with: "スーパー大阪店")
    end

    it "内容量が入力済みになっている" do
      expect(page).to have_field("内容量", with: "5")
    end

    it "単位／内容量が入力済みになっている" do
      expect(page).to have_field("単位（内容量）", with: "枚")
    end

    it "パック数が入力済みになっている" do
      expect(page).to have_field("パック数", with: "3")
    end

    it "単位／パック数が入力済みになっている" do
      expect(page).to have_field("単位（パック数）", with: "パック")
    end

    it "価格が入力済みになっている" do
      expect(page).to have_field("価格", with: "210")
    end

    it "登録日が入力済みになっている" do
      expect(page).to have_field("登録日", with: "2026-03-13")
    end
  end

  # ─── 更新操作 ────────────────────────────────────────────────────────────────
  describe "更新操作" do
    before do
      driven_by ENV['CI'] ? :selenium_chrome_headless : :remote_chrome
      sign_in user
      visit edit_purchase_path(purchase)
    end
    context "内容を変更して更新した場合" do
      before do
        fill_in "メーカー名", with: "プリマハム"
        fill_in "価格", with: 300
        click_button "この内容で更新する"
      end

      it "商品詳細画面に遷移する" do
        expect(page).to have_current_path(item_path(item))
      end
    end

    context "商品名を空にして更新した場合" do
      before do
        fill_in "商品名", with: ""
        click_button "この内容で更新する"
      end

      it "エラーメッセージが表示される" do
        expect(page).to have_css("div", text: /エラー|error|blank|入力/i)
      end

      it "編集画面に留まる" do
        expect(current_path).to eq edit_purchase_path(purchase)
      end
    end
  end
end
