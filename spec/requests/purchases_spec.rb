require "rails_helper"

RSpec.describe "Purchase", type: :request do
  let(:user) { create(:user) }
  let(:item) { create(:item, user: user, name: "牛乳") }
  let(:content_unit) { create(:content_unit, user: user, name: "ml") }

  describe "GET /items/:item_id/purchases（購入履歴一覧）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get item_purchases_path(item)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "購入履歴が0件の場合" do
        before { get item_purchases_path(item) }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "「購入履歴がありません」が表示される" do
          expect(response.body).to include("購入履歴がありません")
        end

        it "商品名が表示される" do
          expect(response.body).to include("牛乳")
        end

        it "商品登録画面へのリンクが含まれる" do
          expect(response.body).to include("牛乳")
        end

        it "商品登録画面へのリンクが含まれる" do
          expect(response.body).to include(new_item_registration_path)
        end

        it "商品削除のフォームが含まれる" do
          expect(response.body).to include(item_path(item))
        end
      end

      context "購入履歴が1件以上ある場合" do
        let!(:purchase1) do
          create(:purchase,
          user: user, item: item, content_unit: content_unit,
          price: 200, content_quantity: 1000, unit_price: 0.2, purchased_on: "2026-01-01"
          )
        end
        let!(:purchase2) do
          create(:purchase,
          user: user, item: item, content_unit: content_unit,
          price: 150, content_quantity: 1000, unit_price: 0.15, purchased_on: "2026-01-02"
          )
        end

        before { get item_purchases_path(item) }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "「現在最安値」が表示される" do
          expect(response.body).to include("現在最安値")
        end

        it "「購入履歴」セクションが表示される" do
          expect(response.body).to include("現在最安値")
        end

        it "比較画面へのリンクが含まれる" do
          expect(response.body).to include(comparison_path(purchase_id: purchase2.id))
        end
      end

      context "検索機能（店舗名絞り込み）" do
        let!(:store_a) { create(:store, user: user, name: "店舗A") }
        let!(:store_b) { create(:store, user: user, name: "店舗B") }
        let!(:purchase_a) do
          create(:purchase, user: user, item: item, content_unit: content_unit, store: store_a, purchased_on: "2026-01-01")
        end
        let!(:purchase_b) do
          create(:purchase, user: user, item: item, content_unit: content_unit, store: store_b, purchased_on: "2026-01-02")
        end

        it "店舗名で絞り込みできる" do
          get item_purchases_path(item), params: { q: { store_name_cont: "店舗A" } }
          expect(response.body).to include("2026-01-01")
          expect(response.body).not_to include("2026-01-02") # 店舗名で確認すると、datalist idに表示されてしまうので、購入日で確認
        end

        it "該当する店舗がない場合「見つかりませんでした」文言が表示される" do
          get item_purchases_path(item), params: { q: { store_name_cont: "存在しない店舗" } }
          expect(response.body).to include("検索した結果、見つかりませんでした")
        end
      end

      context "他のユーザーの商品にアクセスした場合" do
        let(:other_user) { create(:user) }
        let(:other_item) { create(:item, user: other_user) }

        it "アクセスできない（HTTPステータス404を返す" do
          get item_purchases_path(other_item)
          expect(response).to have_http_status(404)
        end
      end
    end
  end

  describe "GET /items/:item_id/purchases/:id/edit（購入履歴編集画面）" do
    let!(:purchase) do
      create(:purchase, user: user, item: item, content_unit: content_unit, price: 200, content_quantity: 1000)
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get edit_item_purchase_path(item, purchase)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
        get edit_item_purchase_path(item, purchase)
      end

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "「購入履歴編集」文言が表示される" do
        expect(response.body).to include("購入履歴編集")
      end

      it "既存の商品名がフォームに表示される" do
        expect(response.body).to include("牛乳")
      end

      it "更新フォームの送信先パスが含まれる" do
        expect(response.body).to include(item_purchase_path(item, purchase))
      end
    end

    context "他のユーザーの購入履歴にアクセスした場合" do
      let(:other_user) { create(:user) }
      let(:other_item) { create(:item, user: other_user) }
      let(:other_content_unit) { create(:content_unit, user: other_user) }
      let!(:other_purchase) do
        create(:purchase, user: other_user, item: other_item, content_unit: other_content_unit)
      end

      before { sign_in user }

      it "アクセスできない（HTTPステータス404を返す" do
        get edit_item_purchase_path(other_item, other_purchase)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "PATCH /items/:item_id/purchases/:id（購入履歴更新）" do
    let!(:purchase) do
      create(:purchase,
        user: user, item: item, content_unit: content_unit,
        price: 200, content_quantity: 1000, brand: nil
        )
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        patch item_purchase_path(item, purchase), params: { purchase_updates: { item_name: "test" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }
      let(:valid_params) do
        {
          purchase_updates: {
            category_name: "食品",
            item_name: "牛乳",
            brand: "明治",
            content_quantity: 1000,
            content_unit_name: "ml",
            pack_quantity: 1,
            pack_unit_name: "",
            store_name: "スーパーA",
            purchased_on: "2026-01-01",
            price: 250,
            tax_rate: 8
          }
        }
      end

      context "パラメータが有効な場合" do
        it "価格が更新される" do
          patch item_purchase_path(item, purchase), params: valid_params
          expect(purchase.reload.price).to eq(250)
        end

        it "ブランドが更新される" do
          patch item_purchase_path(item, purchase), params: valid_params
          expect(purchase.reload.brand).to eq("明治")
        end

        it "購入履歴一覧へリダイレクトされる" do
          patch item_purchase_path(item, purchase), params: valid_params
          expect(response).to redirect_to(item_purchases_path(item))
        end

        it "フラッシュメッセージが設定される" do
          patch item_purchase_path(item, purchase), params: valid_params
          expect(flash[:success]).to eq("商品情報の詳細編集に成功しました")
        end
      end

      context "パラメータが無効な場合" do
        let(:invalid_params) do
          {
            purchase_updates: valid_params[:purchase_updates].merge(item_name: "")
          }
        end

        it "更新されない" do
          original_price = purchase.price
          patch item_purchase_path(item, purchase), params: invalid_params
          expect(purchase.reload.price).to eq(original_price)
        end

        it "HTTPステータス422を返す" do
          patch item_purchase_path(item, purchase), params: invalid_params
          expect(response).to have_http_status(422)
        end

        it "編集フォームが再表示される" do
          patch item_purchase_path(item, purchase), params: invalid_params
          expect(response.body).to include("購入履歴編集")
        end
      end

      context "他のユーザーの購入履歴を更新しようとした場合" do
        let(:other_user) { create(:user) }
        let(:other_item) { create(:item, user: other_user) }
        let(:other_content_unit) { create(:content_unit, user: other_user) }
        let!(:other_purchase) do
          create(:purchase, user: other_user, item: other_item, content_unit: other_content_unit, price: 999)
        end

        it "更新されない" do
          patch item_purchase_path(other_item, other_purchase), params: valid_params
          expect(other_purchase.reload.price).to eq(999)
        end

        it "HTTPステータス404を返す" do
          patch item_purchase_path(other_item, other_purchase), params: valid_params
          expect(response).to have_http_status(404)
        end
      end
    end
  end

  describe "DELETE /items/:item_id/purchases/:id（購入履歴削除）" do
    let!(:purchase) do
      create(:purchase, user: user, item: item, content_unit: content_unit)
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        delete item_purchase_path(item, purchase)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "削除されない" do
        expect { delete item_purchase_path(item, purchase) }.not_to change(Purchase, :count)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "購入履歴が1件削除される" do
        expect { delete item_purchase_path(item, purchase) }.to change(Purchase, :count).by(-1)
      end

      it "購入履歴一覧へリダイレクトされる" do
        delete item_purchase_path(item, purchase)
        expect(response).to redirect_to(item_purchases_path(item))
      end

      it "フラッシュメッセージが設定される" do
        delete item_purchase_path(item, purchase)
        expect(flash[:success]).to eq("購入履歴を削除しました")
      end

      context "他のユーザーの購入履歴の場合" do
        let(:other_user) { create(:user) }
        let(:other_item) { create(:item, user: other_user) }
        let(:other_content_unit) { create(:content_unit, user: other_user) }
        let!(:other_purchase) do
          create(:purchase, user: other_user, item: other_item, content_unit: other_content_unit)
        end

        it "削除されない" do
          expect { delete item_purchase_path(other_item, other_purchase) }.not_to change(Purchase, :count)
        end

        it "HTTPステータス404を返す" do
          delete item_purchase_path(other_item, other_purchase)
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
