require 'rails_helper'

# 共通の一覧・登録・編集・削除は spec/support/shared_examples/master_management.rb で定義
RSpec.describe "マスタ管理", type: :system do
  describe "カテゴリー管理" do
    it_behaves_like "マスタ管理画面",
                    factory: :category, label: "カテゴリー", field_label: "カテゴリー名", max_length: 30,
                    index_path: :categories_path, new_path: :new_category_path, edit_path: :edit_category_path,
                    sample_name: "飲料"
  end

  describe "店舗管理" do
    it_behaves_like "マスタ管理画面",
                    factory: :store, label: "店舗", field_label: "店舗名", max_length: 30,
                    index_path: :stores_path, new_path: :new_store_path, edit_path: :edit_store_path,
                    sample_name: "スーパーA"
  end

  describe "単位（内容量）管理" do
    it_behaves_like "マスタ管理画面",
                    factory: :content_unit, label: "単位（内容量）", field_label: "単位（内容量）", max_length: 10,
                    index_path: :content_units_path, new_path: :new_content_unit_path, edit_path: :edit_content_unit_path,
                    sample_name: "ml"

    # 購入履歴で使用中の単位は削除できない（has_many :purchases, dependent: :restrict_with_error）
    describe "購入履歴で使用中の単位の削除", js: true do
      let(:user) { create(:user) }
      let!(:content_unit) { create(:content_unit, user: user, name: "ml") }
      let(:item) { create(:item, user: user, category: create(:category, user: user)) }

      before do
        create(:purchase, :only_required_purchase, user: user, item: item, content_unit: content_unit)
        sign_in user
        visit content_units_path
      end

      # スワイプ操作は spec/support/swipe_helpers.rb で定義
      it "削除できず、エラーメッセージが表示される" do
        swipe_and_click_delete(find(".swipe-card", text: "ml"))
        within("#turbo-confirm") { click_button "削除する" }

        expect(page).to have_css("main > div.bg-flash-error-bg", text: "購入履歴があるため削除することができません")
        expect(page).to have_css(".swipe-card", text: "ml")
        expect(ContentUnit.exists?(content_unit.id)).to be true
      end
    end
  end
end
