require 'rails_helper'

RSpec.describe "商品登録完了画面", type: :system do
  let(:user) { create(:user) }
  let(:item) { create(:item, name: "牛乳", user: user) }
  let(:content_unit) { create(:content_unit, name: "ml", user: user) }
  let(:purchase) do
    create(:purchase, :only_required_purchase, user: user, item: item, content_unit: content_unit,
                      content_quantity: 500, pack_quantity: 1, price: 550, tax_rate: 10)
  end

  before do
    driven_by(:rack_test)
    sign_in user
    visit complete_item_registration_path(item_id: item.id, purchase_id: purchase.id)
  end

  describe "画面表示" do
    it "登録完了のメッセージが表示される" do
      expect(page).to have_content("登録しました")
    end

    it "登録した商品の内容が表示される" do
      expect(page).to have_content("牛乳")
      expect(page).to have_content("1mlあたりの単価")
      expect(page).to have_content("1.00")
      expect(page).to have_content("価格（税率10%）")
      expect(page).to have_content("¥550")
    end
  end

  describe "画面遷移" do
    it "「詳細情報を追加する」から購入履歴編集画面に遷移できる" do
      click_link "詳細情報を追加する"
      expect(page).to have_current_path(edit_item_purchase_path(item, purchase))
    end

    it "「一覧画面に戻る」から商品一覧画面に遷移できる" do
      click_link "一覧画面に戻る"
      expect(page).to have_current_path(items_path)
    end

    it "「もう1件登録する」から商品登録画面に遷移できる" do
      click_link "もう1件登録する"
      expect(page).to have_current_path(new_item_registration_path)
    end
  end
end
