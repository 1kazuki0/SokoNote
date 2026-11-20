require 'rails_helper'

RSpec.describe "購入履歴編集画面", type: :system do
  let(:user) { create(:user) }
  let(:category) { create(:category, name: "飲料", user: user) }
  let(:item) { create(:item, name: "牛乳", category: category, user: user) }
  let(:store) { create(:store, name: "スーパーA", user: user) }
  let(:content_unit) { create(:content_unit, name: "ml", user: user) }
  let(:pack_unit) { create(:pack_unit, name: "本", user: user) }
  let!(:purchase) do
    create(:purchase, user: user, item: item, store: store, content_unit: content_unit, pack_unit: pack_unit,
                      brand: "明治", content_quantity: 500, pack_quantity: 2, price: 432, tax_rate: 8,
                      purchased_on: "2026-10-01")
  end

  before do
    driven_by(:rack_test)
    sign_in user
    visit edit_item_purchase_path(item, purchase)
  end

  describe "画面表示" do
    it "登録済みの値が初期表示される" do
      expect(page).to have_field("カテゴリー", with: "飲料")
      expect(page).to have_field("商品名", with: "牛乳")
      expect(page).to have_field("店舗名", with: "スーパーA")
      expect(page).to have_field("ブランド名", with: "明治")
      expect(page).to have_field("単位（内容量）", with: "ml")
      expect(page).to have_field("包装数（セット品）", with: "2")
      expect(page).to have_field("単位（包装数）", with: "本")
      expect(page).to have_field("登録日", with: "2026-10-01")
      expect(page).to have_field("価格", with: "432")
      expect(page).to have_checked_field("tax-8")
    end

    it "更新ボタンが表示される" do
      expect(page).to have_button("内容を確認して更新する")
    end
  end

  describe "購入履歴の更新" do
    context "入力値が正常な場合" do
      it "更新に成功し、購入履歴一覧画面に遷移する" do
        fill_in "店舗名", with: "スーパーB"
        fill_in "価格", with: 300
        choose "tax-none"
        click_button "内容を確認して更新する"
        expect(page).to have_current_path(item_purchases_path(item))
        expect(page).to have_content("商品情報の詳細編集に成功しました")
        purchase.reload
        expect(purchase.store.name).to eq "スーパーB"
        expect(purchase.price).to eq 300
        expect(purchase.tax_rate).to eq 0
      end

      it "任意項目を空にして更新できる" do
        fill_in "カテゴリー", with: ""
        fill_in "店舗名", with: ""
        fill_in "ブランド名", with: ""
        fill_in "単位（包装数）", with: ""
        click_button "内容を確認して更新する"
        expect(page).to have_content("商品情報の詳細編集に成功しました")
        purchase.reload
        expect(purchase.item.category).to be_nil
        expect(purchase.store).to be_nil
        expect(purchase.brand).to be_nil
        expect(purchase.pack_unit).to be_nil
      end
    end

    context "必須項目が未入力の場合" do
      it "更新に失敗し、エラーメッセージが表示される" do
        fill_in "商品名", with: ""
        fill_in "価格", with: ""
        click_button "内容を確認して更新する"
        expect(page).to have_current_path(item_purchase_path(item, purchase))
        expect(page).to have_content("購入履歴更新に失敗しました")
        expect(page).to have_content("商品名を入力してください")
        expect(page).to have_content("価格を入力してください")
        expect(purchase.reload.price).to eq 432
      end
    end

    context "包装数が0の場合" do
      it "更新に失敗し、エラーメッセージが表示される" do
        fill_in "包装数（セット品）", with: 0
        click_button "内容を確認して更新する"
        expect(page).to have_content("包装数（セット品）は1以上の値にしてください")
      end
    end
  end

  describe "商品名の変更" do
    context "変更前の商品に他の購入履歴がない場合" do
      it "変更前の商品が削除される" do
        fill_in "商品名", with: "低脂肪乳"
        click_button "内容を確認して更新する"
        expect(page).to have_content("商品情報の詳細編集に成功しました")
        expect(user.items.pluck(:name)).to eq [ "低脂肪乳" ]
      end
    end

    context "変更前の商品に他の購入履歴がある場合" do
      before { create(:purchase, user: user, item: item) }

      it "変更前の商品は削除されない" do
        fill_in "商品名", with: "低脂肪乳"
        click_button "内容を確認して更新する"
        expect(page).to have_content("商品情報の詳細編集に成功しました")
        expect(user.items.pluck(:name)).to contain_exactly("牛乳", "低脂肪乳")
      end
    end

    context "登録済みの別の商品名に変更した場合" do
      let!(:other_item) { create(:item, name: "豆乳", user: user) }

      it "既存の商品に購入履歴が移動する" do
        fill_in "商品名", with: "豆乳"
        click_button "内容を確認して更新する"
        expect(page).to have_current_path(item_purchases_path(other_item))
        expect(purchase.reload.item).to eq other_item
      end
    end
  end
end
