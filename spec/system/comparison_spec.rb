require "rails_helper"

RSpec.describe "比較画面", type: :system do
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
  end

  # ─── 画面の表示 ──────────────────────────────────────────────────────────────
  describe "画面の表示" do
    before { visit comparison_path }

    it "タイトルに「VS どちらがお得？」と表示される" do
      expect(page).to have_content("VS どちらがお得？")
    end

    it "「商品A」が表示される" do
      expect(page).to have_content("商品A")
    end

    it "「商品B」が表示される" do
      expect(page).to have_content("商品B")
    end

    context "商品Aフォーム" do
      it "内容量の入力欄が表示される" do
        expect(page).to have_field("purchase_a[content_quantity]")
      end

      it "パック数の入力欄が表示される" do
        expect(page).to have_field("purchase_a[pack_quantity]")
      end

      it "価格の入力欄が表示される" do
        expect(page).to have_field("purchase_a[price]")
      end

      it "税率の選択肢が3つ表示される（税抜・8%・10%）" do
        within("[data-compare-target='cardA']") do
          expect(page).to have_content("税抜")
          expect(page).to have_content("8%")
          expect(page).to have_content("10%")
        end
      end

      it "デフォルトで「税抜」が選択されている" do
        expect(page).to have_checked_field("tax-none-a")
      end

      it "単価表示エリアの初期値が「---」になっている" do
        expect(page).to have_css("[data-compare-target='resultA']", text: "---")
      end

      it "「Aを登録する」ボタンが表示される" do
        expect(page).to have_button("Aを登録する")
      end
    end

    context "商品Bフォーム" do
      it "内容量の入力欄が表示される" do
        expect(page).to have_field("purchase_b[content_quantity]")
      end

      it "パック数の入力欄が表示される" do
        expect(page).to have_field("purchase_b[pack_quantity]")
      end

      it "価格の入力欄が表示される" do
        expect(page).to have_field("purchase_b[price]")
      end

      it "税率の選択肢が3つ表示される（税抜・8%・10%）" do
        within("[data-compare-target='cardB']") do
          expect(page).to have_content("税抜")
          expect(page).to have_content("8%")
          expect(page).to have_content("10%")
        end
      end

      it "デフォルトで「税抜」が選択されている" do
        expect(page).to have_checked_field("tax-none-b")
      end

      it "単価表示エリアの初期値が「---」になっている" do
        expect(page).to have_css("[data-compare-target='resultB']", text: "---")
      end

      it "「Bを登録する」ボタンが表示される" do
        expect(page).to have_button("Bを登録する")
      end
    end
  end

  # ─── purchase_idを渡した場合（商品詳細画面からの遷移） ────────────────────────
  describe "purchase_idパラメータあり" do
    before { visit comparison_path(purchase_id: purchase.id) }

    it "商品Aに購入データの内容量が入力済みになっている" do
      expect(page).to have_field("purchase_a[content_quantity]", with: "5")
    end

    it "商品Aに購入データのパック数が入力済みになっている" do
      expect(page).to have_field("purchase_a[pack_quantity]", with: "3")
    end

    it "商品Aに購入データの価格が入力済みになっている" do
      expect(page).to have_field("purchase_a[price]", with: "210")
    end
  end

  # ─── 「Aを登録する」ボタン ────────────────────────────────────────────────────
  describe "「Aを登録する」ボタン" do
    before { visit comparison_path }

    it "クリックすると商品新規登録Step1画面に遷移する" do
      click_button "Aを登録する"
      expect(current_path).to eq new_step1_items_path
    end
  end

  # ─── 「Bを登録する」ボタン ────────────────────────────────────────────────────
  describe "「Bを登録する」ボタン" do
    before { visit comparison_path }

    it "クリックすると商品新規登録Step1画面に遷移する" do
      click_button "Bを登録する"
      expect(current_path).to eq new_step1_items_path
    end
  end

  # ─── 単価計算（JavaScript） ──────────────────────────────────────────────────
  # 単価 = 価格 ÷ (1 + 税率/100) ÷ 内容量 ÷ パック数
  describe "単価計算" do
    before do
      driven_by ENV['CI'] ? :selenium_chrome_headless : :remote_chrome
      sign_in user
      visit comparison_path
    end

    context "商品Aの値を入力した場合" do
      context "税抜（税率0%）の場合" do
        before do
          # 単価 = 300 ÷ 1.0 ÷ 500 ÷ 2 = 0.30
          fill_in "purchase_a[content_quantity]", with: 500
          fill_in "purchase_a[pack_quantity]",    with: 2
          fill_in "purchase_a[price]",            with: 300
        end

        it "商品Aの単価が計算されて表示される" do
          expect(page).to have_css("[data-compare-target='resultA']", text: "0.30")
        end
      end

      context "税率8%の場合" do
        before do
          # 単価 = 216 ÷ 1.08 ÷ 200 ÷ 1 = 1.00
          fill_in "purchase_a[content_quantity]", with: 200
          fill_in "purchase_a[pack_quantity]",    with: 1
          fill_in "purchase_a[price]",            with: 216
          find("label[for='tax-8-a']").click
        end

        it "税率を考慮した単価が計算される" do
          expect(page).to have_css("[data-compare-target='resultA']", text: "1.00")
        end
      end

      context "税率10%の場合" do
        before do
          # 単価 = 110 ÷ 1.10 ÷ 100 ÷ 1 = 1.00
          fill_in "purchase_a[content_quantity]", with: 100
          fill_in "purchase_a[pack_quantity]",    with: 1
          fill_in "purchase_a[price]",            with: 110
          find("label[for='tax-10-a']").click
        end

        it "税率を考慮した単価が計算される" do
          expect(page).to have_css("[data-compare-target='resultA']", text: "1.00")
        end
      end

      context "未入力の項目がある場合" do
        before do
          fill_in "purchase_a[content_quantity]", with: 500
          # pack_quantityとpriceは未入力
        end

        it "単価が「---」のままになっている" do
          expect(page).to have_css("[data-compare-target='resultA']", text: "---")
        end
      end
    end

    context "商品Bの値を入力した場合" do
      before do
        # 単価 = 200 ÷ 1.0 ÷ 400 ÷ 1 = 0.50
        fill_in "purchase_b[content_quantity]", with: 400
        fill_in "purchase_b[pack_quantity]",    with: 1
        fill_in "purchase_b[price]",            with: 200
      end

      it "商品Bの単価が計算されて表示される" do
        expect(page).to have_css("[data-compare-target='resultB']", text: "0.50")
      end
    end

    context "AとBの両方に値を入力した場合" do
      context "Aの方が安い場合" do
        before do
          # A単価 = 300 ÷ 1.0 ÷ 500 ÷ 2 = 0.30
          fill_in "purchase_a[content_quantity]", with: 500
          fill_in "purchase_a[pack_quantity]",    with: 2
          fill_in "purchase_a[price]",            with: 300
          # B単価 = 200 ÷ 1.0 ÷ 400 ÷ 1 = 0.50
          fill_in "purchase_b[content_quantity]", with: 400
          fill_in "purchase_b[pack_quantity]",    with: 1
          fill_in "purchase_b[price]",            with: 200
        end

        it "Aに「おトク！」バッジが表示される" do
          expect(page).not_to have_css("[data-compare-target='badgeA'].invisible")
        end

        it "Bに「おトク！」バッジが表示されない" do
          expect(page).to have_css("[data-compare-target='badgeB'].invisible", visible: :all)
        end

        it "「A商品の方が〇〇円安い！」と表示される" do
          expect(page).to have_css("[data-compare-target='compareResultItem']", text: "A商品の方が0.20円安い！")
        end
      end

      context "Bの方が安い場合" do
        before do
          # A単価 = 200 ÷ 1.0 ÷ 400 ÷ 1 = 0.50
          fill_in "purchase_a[content_quantity]", with: 400
          fill_in "purchase_a[pack_quantity]",    with: 1
          fill_in "purchase_a[price]",            with: 200
          # B単価 = 300 ÷ 1.0 ÷ 500 ÷ 2 = 0.30
          fill_in "purchase_b[content_quantity]", with: 500
          fill_in "purchase_b[pack_quantity]",    with: 2
          fill_in "purchase_b[price]",            with: 300
        end

        it "Bに「おトク！」バッジが表示される" do
          expect(page).not_to have_css("[data-compare-target='badgeB'].invisible")
        end

        it "Aに「おトク！」バッジが表示されない" do
          expect(page).to have_css("[data-compare-target='badgeA'].invisible", visible: :all)
        end

        it "「B商品の方が〇〇円安い！」と表示される" do
          expect(page).to have_css("[data-compare-target='compareResultItem']", text: "B商品の方が0.20円安い！")
        end
      end

      context "AとBの単価が同じ場合" do
        before do
          # A単価 = 100 ÷ 1.0 ÷ 100 ÷ 1 = 1.00
          fill_in "purchase_a[content_quantity]", with: 100
          fill_in "purchase_a[pack_quantity]",    with: 1
          fill_in "purchase_a[price]",            with: 100
          # B単価 = 100 ÷ 1.0 ÷ 100 ÷ 1 = 1.00
          fill_in "purchase_b[content_quantity]", with: 100
          fill_in "purchase_b[pack_quantity]",    with: 1
          fill_in "purchase_b[price]",            with: 100
        end

        it "「同じ価格！」と表示される" do
          expect(page).to have_css("[data-compare-target='compareResultItem']", text: "同じ価格！")
        end
      end

      context "片方だけ入力されている場合" do
        before do
          fill_in "purchase_a[content_quantity]", with: 500
          fill_in "purchase_a[pack_quantity]",    with: 2
          fill_in "purchase_a[price]",            with: 300
          # Bは未入力
        end

        it "比較結果が表示されない" do
          expect(page).to have_css("[data-compare-target='compareResultItem'].invisible", visible: :all)
        end
      end
    end

    context "purchase_idパラメータありで遷移した場合" do
      before { visit comparison_path(purchase_id: purchase.id) }

      it "商品Aの単価がconnect時に自動計算されて表示される" do
        # 単価 = 210 ÷ 1.0 ÷ 5 ÷ 3 = 14.00
        expect(page).to have_css("[data-compare-target='resultA']", text: "14.00")
      end
    end
  end
end
