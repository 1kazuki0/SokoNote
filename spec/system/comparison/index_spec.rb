require 'rails_helper'

# 単価計算・比較結果の表示はStimulus（compare_controller）で行われるため、全てJSドライバで実行する
RSpec.describe "商品比較画面", type: :system do
  let(:user) { create(:user) }
  let(:item) { create(:item, name: "牛乳", user: user) }
  let(:ml) { create(:content_unit, name: "ml", user: user) }
  # 単価0.40円（432円 ÷ 1.08 ÷ 500ml ÷ 2本）
  let(:lowest_purchase) do
    create(:purchase, user: user, item: item, content_unit: ml,
                      content_quantity: 500, pack_quantity: 2, price: 432, tax_rate: 8)
  end

  before { sign_in user }

  # side: "a" or "b"、tax: "none" / "8" / "10"
  def fill_in_purchase(side, content_quantity:, pack_quantity:, price:, tax: nil)
    fill_in "purchase_#{side}[content_quantity]", with: content_quantity
    fill_in "purchase_#{side}[pack_quantity]", with: pack_quantity
    fill_in "purchase_#{side}[price]", with: price
    # 税率のラジオボタンは非表示のため、ラベルをクリックして選択する
    choose "tax-#{tax}-#{side}", allow_label_click: true if tax
  end

  # 入力欄を空にする（fill_inで空文字を指定するとinputイベントが発火しないため、バックスペースで削除する）
  def clear_field(locator)
    fill_in locator, with: "", fill_options: { clear: :backspace }
  end

  def unit_price(side)
    find("[data-compare-target='result#{side.upcase}']")
  end

  def compare_result
    find("[data-compare-target='compareResultItem']")
  end

  def expect_compare_result_hidden
    expect(page).not_to have_css("[data-compare-target='compareResultItem']")
  end

  describe "購入履歴を指定せずに表示した場合" do
    before { visit comparison_path }

    it "商品A・商品Bの入力フォームが表示される" do
      expect(page).to have_css("h2", text: "商品A")
      expect(page).to have_css("h2", text: "商品B")
      expect(page).to have_field("purchase_a[content_quantity]", with: "")
      expect(page).to have_field("purchase_b[content_quantity]", with: "")
    end

    it "税率は税抜が選択されている" do
      expect(page).to have_checked_field("tax-none-a", visible: :all)
      expect(page).to have_checked_field("tax-none-b", visible: :all)
    end

    it "単価は「---」と表示され、比較結果は表示されない" do
      expect(unit_price("a")).to have_text("---")
      expect(unit_price("b")).to have_text("---")
      expect_compare_result_hidden
    end
  end

  describe "購入履歴一覧の「この商品で比較する」から遷移した場合" do
    before do
      lowest_purchase
      visit item_purchases_path(item)
      click_link "この商品で比較する"
    end

    it "比較画面に遷移し、商品名が表示される" do
      expect(page).to have_current_path(comparison_path(purchase_id: lowest_purchase.id))
      expect(page).to have_css("h2", text: "牛乳A")
      expect(page).to have_css("h2", text: "牛乳B")
    end

    it "Aに最安値の購入履歴の値が初期表示され、単価が計算される" do
      expect(page).to have_field("purchase_a[content_quantity]", with: "500.0")
      expect(page).to have_field("purchase_a[pack_quantity]", with: "2")
      expect(page).to have_field("purchase_a[price]", with: "432")
      expect(page).to have_checked_field("tax-8-a", visible: :all)
      expect(unit_price("a")).to have_text("0.40")
    end

    it "Bは未入力の状態で表示される" do
      expect(page).to have_field("purchase_b[content_quantity]", with: "")
      expect(unit_price("b")).to have_text("---")
    end
  end

  describe "単価の計算" do
    before { visit comparison_path }

    it "内容量・パック数・価格を入力すると単価が計算される" do
      fill_in_purchase("a", content_quantity: 500, pack_quantity: 2, price: 400)
      expect(unit_price("a")).to have_text("0.40")
    end

    it "税率を切り替えると税抜価格で単価が再計算される" do
      fill_in_purchase("a", content_quantity: 500, pack_quantity: 1, price: 550)
      expect(unit_price("a")).to have_text("1.10")
      choose "tax-10-a", allow_label_click: true
      expect(unit_price("a")).to have_text("1.00")
      choose "tax-8-a", allow_label_click: true
      expect(unit_price("a")).to have_text("1.02")
    end

    it "未入力・0の項目がある場合は「---」と表示される" do
      fill_in_purchase("a", content_quantity: 500, pack_quantity: 1, price: 400)
      expect(unit_price("a")).to have_text("0.80")
      clear_field "purchase_a[pack_quantity]"
      expect(unit_price("a")).to have_text("---")
      fill_in "purchase_a[pack_quantity]", with: 1
      expect(unit_price("a")).to have_text("0.80")
      fill_in "purchase_a[pack_quantity]", with: 0
      expect(unit_price("a")).to have_text("---")
    end
  end

  describe "比較結果の表示" do
    before { visit comparison_path }

    it "Aの方が安い場合、差額とAの「おトク！」が表示される" do
      fill_in_purchase("a", content_quantity: 500, pack_quantity: 1, price: 200)
      fill_in_purchase("b", content_quantity: 500, pack_quantity: 1, price: 250)
      expect(compare_result).to have_text("Aの方が0.10円安い！")
      expect(page).to have_css("[data-compare-target='badgeA']", text: "おトク！")
      expect(page).not_to have_css("[data-compare-target='badgeB']", text: "おトク！")
      expect(page).to have_css("[data-compare-target='cardA'].border-primary")
    end

    it "Bの方が安い場合、差額とBの「おトク！」が表示される" do
      fill_in_purchase("a", content_quantity: 500, pack_quantity: 2, price: 432, tax: "8")
      fill_in_purchase("b", content_quantity: 1000, pack_quantity: 1, price: 300, tax: "10")
      expect(unit_price("b")).to have_text("0.27")
      expect(compare_result).to have_text("Bの方が0.13円安い！")
      expect(page).to have_css("[data-compare-target='badgeB']", text: "おトク！")
      expect(page).not_to have_css("[data-compare-target='badgeA']", text: "おトク！")
      expect(page).to have_css("[data-compare-target='cardB'].border-primary")
    end

    it "単価が同じ場合、「同じ価格！」と表示され「おトク！」は表示されない" do
      fill_in_purchase("a", content_quantity: 500, pack_quantity: 1, price: 200)
      fill_in_purchase("b", content_quantity: 1000, pack_quantity: 2, price: 800)
      expect(compare_result).to have_text("同じ価格！")
      expect(page).not_to have_css("[data-compare-target^='badge']", text: "おトク！")
    end

    it "片方の入力を消すと比較結果が非表示になる" do
      fill_in_purchase("a", content_quantity: 500, pack_quantity: 1, price: 200)
      fill_in_purchase("b", content_quantity: 500, pack_quantity: 1, price: 250)
      expect(compare_result).to have_text("Aの方が0.10円安い！")
      clear_field "purchase_b[price]"
      expect(unit_price("b")).to have_text("---")
      expect_compare_result_hidden
      expect(page).not_to have_css("[data-compare-target='badgeA']", text: "おトク！")
    end
  end

  describe "商品登録への引き継ぎ" do
    context "購入履歴から遷移した場合" do
      before { visit comparison_path(purchase_id: lowest_purchase.id) }

      it "「Aで登録する」で商品登録画面にAの入力値と商品名・単位が引き継がれる" do
        click_button "Aで登録する"
        expect(page).to have_current_path(new_item_registration_path, ignore_query: true)
        expect(page).to have_field("商品名", with: "牛乳")
        expect(page).to have_field("内容量", with: "500.0")
        expect(page).to have_field("単位", with: "ml")
        expect(page).to have_field("価格", with: "432")
        expect(page).to have_checked_field("tax-8", visible: :all)
      end

      it "「Bで登録する」で商品登録画面にBの入力値と商品名・単位が引き継がれる" do
        fill_in_purchase("b", content_quantity: 1000, pack_quantity: 1, price: 300, tax: "10")
        click_button "Bで登録する"
        expect(page).to have_current_path(new_item_registration_path, ignore_query: true)
        expect(page).to have_field("商品名", with: "牛乳")
        expect(page).to have_field("内容量", with: "1000.0")
        expect(page).to have_field("単位", with: "ml")
        expect(page).to have_field("価格", with: "300")
        expect(page).to have_checked_field("tax-10", visible: :all)
      end
    end

    context "購入履歴を指定せずに表示した場合" do
      before { visit comparison_path }

      it "「Aで登録する」で入力値のみが引き継がれ、商品名・単位は空になる" do
        fill_in_purchase("a", content_quantity: 500, pack_quantity: 1, price: 200)
        click_button "Aで登録する"
        expect(page).to have_field("商品名", with: "")
        expect(page).to have_field("内容量", with: "500.0")
        expect(page).to have_field("単位", with: "")
        expect(page).to have_field("価格", with: "200")
      end
    end
  end
end
