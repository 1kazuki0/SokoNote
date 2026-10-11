require 'rails_helper'

RSpec.describe "商品登録画面", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
    sign_in user
  end

  def fill_in_form(item_name:, content_quantity:, content_unit_name:, price:)
    fill_in "商品名", with: item_name
    fill_in "内容量", with: content_quantity
    fill_in "単位", with: content_unit_name
    fill_in "価格", with: price
  end

  describe "画面表示" do
    before { visit new_item_registration_path }

    it "見出しが表示される" do
      expect(page).to have_content("商品情報")
      expect(page).to have_content("価格情報")
    end

    it "各入力欄が表示される" do
      expect(page).to have_field("商品名")
      expect(page).to have_field("内容量")
      expect(page).to have_field("単位")
      expect(page).to have_field("価格")
    end

    it "消費税率の選択肢が表示され、税抜が選択されている" do
      expect(page).to have_checked_field("tax-none")
      expect(page).to have_unchecked_field("tax-8")
      expect(page).to have_unchecked_field("tax-10")
    end

    it "登録ボタンが表示される" do
      expect(page).to have_button("内容を確認して登録する")
    end
  end

  describe "入力候補（datalist）" do
    let(:other_user) { create(:user) }

    before do
      create(:item, name: "牛乳", user: user)
      create(:content_unit, name: "ml", user: user)
      create(:item, name: "他人の商品", user: other_user)
      create(:content_unit, name: "他人の単位", user: other_user)
      visit new_item_registration_path
    end

    it "登録済みの商品名が商品名の候補に含まれる" do
      expect(page).to have_css("datalist#items_list option[value='牛乳']", visible: false)
    end

    it "登録済みの単位が単位の候補に含まれる" do
      expect(page).to have_css("datalist#content_units_list option[value='ml']", visible: false)
    end

    it "他のユーザーの商品名・単位は候補に含まれない" do
      expect(page).not_to have_css("datalist#items_list option[value='他人の商品']", visible: false)
      expect(page).not_to have_css("datalist#content_units_list option[value='他人の単位']", visible: false)
    end
  end

  describe "商品登録" do
    before { visit new_item_registration_path }

    context "入力値が正常な場合" do
      it "登録に成功し、登録完了画面に遷移する" do
        fill_in_form(item_name: "牛乳", content_quantity: 500, content_unit_name: "ml", price: 250)
        expect {
          click_button "内容を確認して登録する"
        }.to change(Item, :count).by(1).and change(Purchase, :count).by(1)
        purchase = Purchase.last
        expect(page).to have_current_path(complete_item_registration_path(item_id: purchase.item_id, purchase_id: purchase.id))
        expect(page).to have_content("登録しました")
        expect(page).to have_content("牛乳")
      end

      it "消費税率を選択した場合、税抜価格で単価が計算される" do
        fill_in_form(item_name: "牛乳", content_quantity: 500, content_unit_name: "ml", price: 550)
        choose "tax-10"
        click_button "内容を確認して登録する"
        expect(page).to have_content("1mlあたりの単価")
        expect(page).to have_content("1.00")
        expect(Purchase.last.tax_rate).to eq 10
      end

      it "前後の空白が取り除かれて登録される" do
        fill_in_form(item_name: "　牛乳 ", content_quantity: 500, content_unit_name: " ml　", price: 250)
        click_button "内容を確認して登録する"
        expect(user.items.pluck(:name)).to eq [ "牛乳" ]
        expect(user.content_units.pluck(:name)).to eq [ "ml" ]
      end
    end

    context "登録済みの商品名・単位を入力した場合" do
      let!(:item) { create(:item, name: "牛乳", user: user) }
      let!(:content_unit) { create(:content_unit, name: "ml", user: user) }

      it "商品・単位は新たに作成されず、既存の商品に購入履歴が追加される" do
        fill_in_form(item_name: "牛乳", content_quantity: 500, content_unit_name: "ml", price: 250)
        expect {
          click_button "内容を確認して登録する"
        }.to change(Item, :count).by(0).and change(ContentUnit, :count).by(0).and change(item.purchases, :count).by(1)
      end
    end

    context "必須項目が未入力の場合" do
      it "登録に失敗し、エラーメッセージが表示される" do
        expect {
          click_button "内容を確認して登録する"
        }.not_to change(Purchase, :count)
        expect(page).to have_current_path(item_registration_path)
        expect(page).to have_content("商品登録に失敗しました")
        expect(page).to have_content("商品名を入力してください")
        expect(page).to have_content("内容量を入力してください")
        expect(page).to have_content("単位を入力してください")
        expect(page).to have_content("価格を入力してください")
      end
    end

    context "商品名が31文字以上の場合" do
      it "登録に失敗し、エラーメッセージが表示される" do
        fill_in_form(item_name: "あ" * 31, content_quantity: 500, content_unit_name: "ml", price: 250)
        click_button "内容を確認して登録する"
        expect(page).to have_content("商品名は30文字以内で入力してください")
      end
    end

    context "単位が11文字以上の場合" do
      it "登録に失敗し、エラーメッセージが表示される" do
        fill_in_form(item_name: "牛乳", content_quantity: 500, content_unit_name: "あ" * 11, price: 250)
        click_button "内容を確認して登録する"
        expect(page).to have_content("単位は10文字以内で入力してください")
      end
    end

    context "内容量・価格が0の場合" do
      it "登録に失敗し、エラーメッセージが表示される" do
        fill_in_form(item_name: "牛乳", content_quantity: 0, content_unit_name: "ml", price: 0)
        click_button "内容を確認して登録する"
        expect(page).to have_content("内容量は0より大きい値にしてください")
        expect(page).to have_content("価格は0より大きい値にしてください")
      end
    end

    context "登録に失敗した場合" do
      it "入力した値が保持される" do
        fill_in_form(item_name: "牛乳", content_quantity: 500, content_unit_name: "ml", price: "")
        choose "tax-8"
        click_button "内容を確認して登録する"
        expect(page).to have_field("商品名", with: "牛乳")
        expect(page).to have_field("単位", with: "ml")
        expect(page).to have_checked_field("tax-8")
      end
    end
  end
end
