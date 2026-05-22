require 'rails_helper'

RSpec.describe "ItemRegistrations", type: :request do
  let(:user) { create(:user) }
  describe "GET /item_registration/new（商品登録画面）" do
    context "ログインしていない場合" do
      before { get new_item_registration_path }

      it "ログイン画面へリダイレクトされる" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "通常アクセス" do
        before { get new_item_registration_path }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "「商品登録」文言が表示される" do
          expect(response.body).to include("商品登録")
        end

        it "送信先パスが含まれる" do
          expect(response.body).to include(item_registration_path)
        end
      end

      context "purchase_aパラメータ付きでアクセスした場合" do
        before do
          get new_item_registration_path, params: {
            purchase_a: {
              item_name: "牛乳",
              content_quantity: "1000", 
              content_unit_name: "ml",
              price: "200",
              tax_rate: "8"
            }
          }
        end

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "パラメータの値がフォームに反映される" do
          expect(response.body).to include("牛乳")
          expect(response.body).to include("1000")
        end
      end

      context "登録済みの商品・単位がある場合" do
        let!(:existing_item) { create(:item, user: user, name: "既存商品") }
        let!(:existing_unit) { create(:content_unit, user: user, name: "ml") }

        before { get new_item_registration_path }

        it "既存商品がdatalistに含まれる" do
          expect(response.body).to include("既存商品")
          expect(response.body).to include("ml")
        end
      end
    end
  end

  describe "POST /item_registration（商品登録処理）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        post item_registration_path, params: { item_registration: {} }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "パラメータが有効な場合" do
        let(:valid_params) do
          {
            item_registrations: {
              item_name: "牛乳",
              content_quantity: 1000,
              content_unit_name: "ml",
              price: 200,
              tax_rate: 8
            }
          }
        end

        it "Itemが1件作成される" do
          expect { post item_registration_path, params: valid_params }.to change(Item, :count).by(1)
        end

        it "Purchaseが1件作成される" do
          expect { post item_registration_path, params: valid_params }.to change(Purchase, :count).by(1)
        end

        it "ContentUnitが1件作成される" do
          expect { post item_registration_path, params: valid_params }.to change(Purchase, :count).by(1)
        end

        it "完了画面へリダイレクトされる" do
          post item_registration_path, params: valid_params
          item = Item.last
          purchase = Purchase.last
          expect(response).to redirect_to(complete_item_registration_path(item_id: item.id, purchase_id: purchase.id))
        end

        context "既存の商品名と同じ名前の場合" do
          let!(:existing_item) { create(:item, user: user, name: "牛乳") }

          it "Itemは新規作成されない" do
            expect { post item_registration_path, params: valid_params }.not_to change(Item, :count)
          end

          it "既存Itemに紐づくPurchaseが作成される" do
            post item_registration_path, params: valid_params
            expect(Purchase.last.item).to eq(existing_item)
          end
        end

        context "既存の単位名と同じ場合" do
          let!(:existing_content_unit) { create(:content_unit, user: user, name: "ml") }

          it "ContentUnitは新規作成されない" do
            expect { post item_registration_path, params: valid_params }.not_to change(ContentUnit, :count)
          end
        end
      end

      context "パラメータが無効な場合" do
        let(:invalid_params) do
          {
            item_registrations: { 
              item_name: "",
              content_quantity: 1000,
              content_unit_name: "ml",
              price: 200,
              tax_rate: 8
            }
          }
        end

        it "Itemが作成されない" do
          expect { post item_registration_path, params: invalid_params }.not_to change(Item, :count)
        end

        it "Purchaseが作成されない" do
          expect { post item_registration_path, params: invalid_params }.not_to change(Purchase, :count)
        end

        it "HTTPステータス422を返す" do
          post item_registration_path, params: invalid_params
          expect(response).to have_http_status(422)
        end

        it "フォームが再表示される" do
          post item_registration_path, params: invalid_params
          expect(response.body).to include("商品登録")
        end

        context "tax_rateが不正な値の場合" do
          let(:invalid_tax_params) do
            {
              item_registrations: {
                item_name: "牛乳",
                content_quantity: 1000,
                content_unit_name: "ml",
                price: 200,
                tax_rate: 5
              }
            }
          end

          it "登録されない" do
            expect { post item_registration_path, params: invalid_tax_params }.not_to change(Purchase, :count)
          end
        end
      end
    end
  end

  describe "GET /item_registration/complete（登録完了画面）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get complete_item_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "商品登録が完了した場合" do
        let!(:item) { create(:item, user: user, name: "牛乳") }
        let!(:content_unit) { create(:content_unit, user: user, name: "ml") }
        let!(:purchase) do
          create(:purchase, item: item, user: user, content_unit: content_unit)
        end

        before { get complete_item_registration_path(item_id: item.id, purchase_id: purchase.id) }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "「登録しました」文言が表示される" do
          expect(response.body).to include("登録しました")
        end

        it "商品名が表示される" do
          expect(response.body).to include("牛乳")
        end

        it "詳細編集画面へのリンクが含まれる" do
          expect(response.body).to include(edit_item_purchase_path(item, purchase))
        end

        it "商品一覧画面へのリンクが含まれる" do
          expect(response.body).to include(items_path)
        end

        it "もう1件登録画面へのリンクが含まれる" do
          expect(response.body).to include(new_item_registration_path)
        end
      end
    end
  end

  describe "GET/item_registration/last_purchase（前回購入情報）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get last_purchase_item_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "指定した商品名の購入履歴が存在する場合" do
        let!(:item) { create(:item, user: user, name: "牛乳") }
        let!(:content_unit) { create(:content_unit, user: user, name: "ml") }
        let!(:purchase) do
          create(:purchase,
            item: item,
            user: user,
            content_unit: content_unit,
            content_quantity: 1000,
            purchased_on: "2026-01-01"
          )
        end

        before do
          get last_purchase_item_registration_path, params: { name: "牛乳" }
        end

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "JSON形式でcontent_quantityとcontent_unit_nameを返す" do
          json = JSON.parse(response.body)
          expect(json["content_quantity"].to_f).to eq(1000.0)
          expect(json["content_unit_name"]).to eq("ml")
        end
      end

      context "指定した商品名が存在しない場合" do
        before { get last_purchase_item_registration_path, params: { name: "存在しない商品" } }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "nil値のJSONを返す" do
          json = JSON.parse(response.body)
          expect(json["content_quantity"]).to be_nil
          expect(json["content_unit_name"]).to be_nil
        end

        context "他のユーザーの商品名を指定した場合" do
          let(:other_user) { create(:user) }
          let!(:other_item) { create(:item, user: other_user, name: "他人の商品") }
          let!(:other_purchase) { create(:purchase, item: other_item, user: other_user) }
        end

        before { get last_purchase_item_registration_path, params: { name: "他人の商品" } }

        it "nil値のJSONを返す（他人のデータは取得できない）" do
          json = JSON.parse(response.body)
          expect(json["content_quantity"]).to be_nil
          expect(json["content_unit_name"]).to be_nil
        end
      end
    end
  end
end

