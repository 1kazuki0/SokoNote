require "rails_helper"

RSpec.describe "Items", type: :request do
  let(:user) { create(:user) }
  describe "GET /items（商品一覧画面）" do
    context "ログインしていない場合" do
      before { get items_path }

      it "ログイン画面へリダイレクトされる" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "商品を1件も登録していない場合" do
        before { get items_path }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "使い方画面へのリンクが含まれる" do
          expect(response.body).to include(guide_path)
        end

        it "商品登録画面へのリンクが含まれる" do
          expect(response.body).to include(new_item_registration_path)
        end

        it "「商品を登録しましょう」文言が含まれる" do
          expect(response.body).to include("商品を登録しましょう")
        end
      end

      context "商品が1件以上登録している場合" do
        let!(:item1) { create(:item, user: user, name: "牛乳") }
        let!(:item2) { create(:item, user: user, name: "パン") }

        before { get items_path }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "自分の商品名が表示される" do
          expect(response.body).to include("牛乳")
          expect(response.body).to include("パン")
        end

        it "検索フォームが表示される" do
          expect(response.body).to include("商品を検索")
        end

        it "商品登録画面へのリンクが含まれる" do
          expect(response.body).to include(new_item_registration_path)
        end

        context "他のユーザーの商品がある場合" do
          let(:other_user) { create(:user) }
          let!(:other_item) { create(:item, user: other_user) }

          it "他のユーザーの商品は表示されない" do
            get items_path
            expect(response.body).not_to include("他人の商品")
          end
        end
      end

      context "検索機能" do
        let!(:milk) { create(:item, user: user, name: "牛乳") }
        let!(:bread) { create(:item, user: user, name: "パン") }

        it "商品名で部分一致検索ができる" do
          get items_path, params: { q: { name_cont: "牛" } }
          expect(response.body).to include("牛乳")
          expect(response.body).not_to include("パン")
        end

        it "検索結果が0件の場合「見つかりませんでした」が表示される" do
          get items_path, params: { q: { name_cont: "存在しない商品" } }
          expect(response.body).to include("検索した結果、見つかりませんでした")
        end
      end

      context "カテゴリ絞り込み" do
        let!(:food_category) { create(:category, user: user, name: "食品") }
        let!(:daily_category) { create(:category, user: user, name: "日用品") }
        let!(:milk) { create(:item, user: user, name: "牛乳", category: food_category) }
        let!(:soap) { create(:item, user: user, name: "石鹸", category: daily_category) }
        let!(:no_category_item) { create(:item, user: user, name: "未分類商品", category: nil) }

        it "特定カテゴリで絞り込みできる" do
          get items_path, params: { q: { category_id_eq: food_category.id } }
          expect(response.body).to include("牛乳")
          expect(response.body).not_to include("石鹸")
        end

        it "カテゴリ未登録の商品だけ絞り込みできる" do
          get items_path, params: { q: { category_id_null: "1" } }
          expect(response.body).to include("未分類商品")
          expect(response.body).not_to include("牛乳")
          expect(response.body).not_to include("石鹸")
        end
      end
    end
  end

  describe "DELETE /items/:id （商品削除）" do
    let!(:item) { create(:item, user: user) }

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        delete item_path(item)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "商品が削除されない" do
        expect { delete item_path(item) }.not_to change(Item, :count)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }
      
      context "購入履歴がない場合" do
        it "商品が削除される" do
          expect { delete item_path(item) }.to change(Item, :count).by(-1)
        end

        it "商品一覧画面へリダイレクトされる" do
          delete item_path(item)
          expect(response).to redirect_to(items_path)
        end

        it "フラッシュメッセージが設定される" do
          delete item_path(item)
          expect(flash[:success]).to include(item.name)
          expect(flash[:success]).to include("削除しました")
        end
      end

      context "購入履歴がある場合" do
        let!(:purchase) { create(:purchase, item: item) }

        it "商品が削除されない" do
          expect{ delete item_path(item) }.not_to change(Item, :count)
        end

        it "購入履歴画面へリダイレクトされる" do
          delete item_path(item)
          expect(response).to redirect_to(item_purchases_path(item))
        end

        it "フラッシュメッセージが設定される" do
          delete item_path(item)
          expect(flash[:error]).to eq("購入履歴がある商品は削除できません")
        end
      end

      context "他のユーザーの商品の場合" do
        let(:other_user) { create(:user) }
        let!(:other_item) { create(:item, user: other_user) }

        it "HTTPステータス404を返す" do
          delete item_path(other_item)
          expect(response).to have_http_status(:not_found)
        end

        it "商品が削除されない" do
          expect {
            begin
              delete item_path(other_item)
            rescue ActiveRecord::RecordNotFound
            end
          }.not_to change(Item, :count)
        end
      end
    end
  end
end
