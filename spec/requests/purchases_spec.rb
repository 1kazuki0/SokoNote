require "rails_helper"

RSpec.describe "Purchase", type: :request do
  let(:user) { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }
  let(:category) { user.categories.create(name: "食品") }
  let(:store) { user.stores.create(name: "スーパー大阪店") }
  let(:item) { category.items.create(name: "ハム", user: user) }
  let(:purchase) { item.purchases.create(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: "3", pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2026/03/13", user: user) }

  describe "GET / edit_purchase(purchase)" do
    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        get edit_purchase_path(purchase)
        expect(response).to have_http_status(302)
      end
    end

    context "ログインしている場合" do
      it "HTTPステータスコード200を返す" do
        sign_in user
        get edit_purchase_path(purchase)
        expect(response).to have_http_status(200)
      end

      context "他のユーザーのpurchaseの場合" do
        let(:other_user) { User.create(name: "other", email: "other@email.com", password: "password") }
        let(:other_category) { other_user.categories.create(name: "食品") }
        let(:other_item) { other_category.items.create(name: "ハム", user: other_user) }
        let(:other_purchase) { other_item.purchases.create(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: "3", pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2026/03/13", user: other_user) }
        it "HTTPステータスコード404を返す" do
          sign_in user
          get edit_purchase_path(other_purchase)
          expect(response).to have_http_status(404)
        end
      end
    end
  end

  describe "PATCH / purchase(purchase)" do
    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        patch purchase_path(purchase)
        expect(response).to have_http_status(302)
      end
    end

    context "ログインしている場合" do
      it "item_pathにリダイレクトされる" do
        sign_in user
        patch purchase_path(purchase), params: { purchase_form: { category_name: "食品", item_name: "ハム", brand: "世界ハム", store: "スーパー大阪店", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, tax_rate: 0, purchased_on: "2026/03/13" } }
        expect(response).to redirect_to item_path(purchase.item)
      end
    end

    context "バリデーションエラーの場合" do
      it "HTTPステータスコード422を返す" do
        sign_in user
        patch purchase_path(purchase), params: { purchase_form: { category_name: "食品", item_name: "ハム", brand: "世界ハム", store: "スーパー大阪店", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, tax_rate: 0, purchased_on: nil } }
        expect(response).to have_http_status(422)
      end
    end

    context "他のユーザーのデータを更新しようとした場合" do
      let(:other_user) { User.create(name: "other", email: "other@email.com", password: "password") }
      let(:other_category) { other_user.categories.create(name: "食品") }
      let(:other_item) { other_category.items.create(name: "ハム", user: other_user) }
      let(:other_purchase) { other_item.purchases.create(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: "3", pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2026/03/13", user: other_user) }
      it "HTTPステータスコード404を返す" do
        sign_in user
        patch purchase_path(other_purchase), params: { purchase_form: { category_name: "食品", item_name: "ハム", brand: "世界ハム", store: "スーパー大阪店", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, tax_rate: 0, purchased_on: "2025/1/1" } }
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "DELETE / purchase(purchase)" do
    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        delete purchase_path(purchase)
        expect(response).to have_http_status(302)
      end
    end

    context "ログインしている場合" do
      it "purchases_pathにリダイレクトされる" do
        sign_in user
        delete purchase_path(purchase)
        expect(response).to redirect_to purchases_path
      end

      it "レコードが1件減る" do
        sign_in user
        purchase # ここで事前にDBにレコードを作っておく count測定のため
        expect { delete purchase_path(purchase) }.to change(Purchase, :count).by(-1)
      end

      context "他のユーザーのデータを削除しようとした場合" do
        let(:other_user) { User.create(name: "other", email: "other@email.com", password: "password") }
        let(:other_category) { other_user.categories.create(name: "食品") }
        let(:other_item) { other_category.items.create(name: "ハム", user: other_user) }
        let(:other_purchase) { other_item.purchases.create(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: "3", pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2026/03/13", user: other_user) }
        it "HTTPステータスコード404を返す" do
          sign_in user
          delete purchase_path(other_purchase)
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
