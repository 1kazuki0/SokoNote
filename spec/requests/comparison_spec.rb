require "rails_helper"

RSpec.describe "Comparison", type: :request do # モデルの存在しないcontrollerのため"Comparison"で文字列指定
  let(:user) { create(:user) }
  describe "GET /comparison（単価比較画面）" do
    context "ログインしていない場合" do
      it "ログイン画面ヘリダイレクトされる" do
        get comparison_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "purchase_idパラメータなしでアクセスした場合" do
        before { get comparison_path }


        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "VS どちらがお得？の文面が表示される" do
          expect(response.body).to include("VS どちらがお得？")
        end

        it "「Aで登録する」ボタンが表示される" do
          expect(response.body).to include("Aで登録する")
        end

        it "「Bで登録する」ボタンが表示される" do
          expect(response.body).to include("Bで登録する")
        end
      end

      context "有効なpurchase_idパラメータでアクセスした場合" do
        let(:item) { create(:item, user: user, name: "牛乳") }
        let(:content_unit) { create(:content_unit, user: user, name: "ml") }
        let(:purchase) do
          create(:purchase,
            user: user, item: item, content_unit: content_unit,
            content_quantity: 1000, price: 200
          )
        end

        before { get comparison_path, params: { purchase_id: purchase.id } }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "商品名が表示される" do
          expect(response.body).to include("牛乳")
        end

        it "purchase_a の商品名が hidden field に含まれる" do
          # item_name の hidden_field を経由してフォームに値が反映される
          expect(response.body).to include('value="牛乳"')
        end

        it "purchase_a の単位名が hidden field に含まれる" do
          expect(response.body).to include('value="ml"')
        end
      end

      context "他のユーザーの purchase_id でアクセスした場合" do
        let(:other_user) { create(:user) }
        let(:other_item) { create(:item, user: other_user) }
        let(:other_content_unit) { create(:content_unit, user: other_user) }
        let(:other_purchase) do
          create(:purchase, user: other_user, item: other_item, content_unit: other_content_unit)
        end

        it "HTTPステータス404を返す" do
          get comparison_path, params: { purchase_id: other_purchase.id }
          expect(response).to have_http_status(404)
        end
      end

      context "存在しない purchase_id でアクセスした場合" do
        it "HTTPステータス404を返す" do
          get comparison_path, params: { purchase_id: 999_999 }
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
