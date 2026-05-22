require 'rails_helper'

RSpec.describe "Stores", type: :request do
  let(:user) { create(:user) }
  describe "GET /stores（店舗一覧）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get stores_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "店舗が0件の場合" do
        before { get stores_path }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "「店舗がありません」が表示される" do
          expect(response.body).to include("店舗がありません")
        end

        it "店舗新規登録画面へのリンクが含まれる" do
          expect(response.body).to include(new_store_path)
        end
      end

      context "店舗が1件以上ある場合" do
        let!(:store1) { create(:store, user: user, name: "店舗A") }
        let!(:store2) { create(:store, user: user, name: "店舗B") }

        before { get stores_path }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "自分の登録した店舗名が表示される" do
          expect(response.body).to include("店舗A")
          expect(response.body).to include("店舗B")
        end

        it "編集画面へのリンクが含まれる" do
          expect(response.body).to include(edit_store_path(store1))
        end

        it "削除リンクが含まれる" do
          expect(response.body).to include(store_path(store1))
        end

        it "店舗追加ボタンのリンクが含まれる" do
          expect(response.body).to include(new_store_path)
        end
      end

      context "他のユーザーの店舗がある場合" do
        let(:other_user) { create(:user) }
        let!(:other_store) { create(:store, user: other_user, name: "他人の店舗") }

        before { get stores_path }

        it "他のユーザーの店舗は表示されない" do
          expect(response.body).not_to include("他人の店舗")
        end
      end
    end
  end

  describe "GET /stores/new(新規登録画面)" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get new_store_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
        get new_store_path
      end

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "「店舗登録」のタイトルが表示される" do
        expect(response.body).to include("店舗登録")
      end

      it "フォームの送信先パスが含まれる" do
        expect(response.body).to include(stores_path)
      end
    end
  end

  describe "POST /stores（新規登録処理）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        post stores_path, params: { store: { name: "店舗A" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "パラメータが有効な場合" do
        let(:valid_params) {  { store: { name: "店舗A" } } }

        it "店舗が1件作成される" do
          expect { post stores_path, params: valid_params }.to change(Store, :count).by(1)
        end

        it "店舗一覧画面へリダイレクトされる" do
          post stores_path, params: valid_params
          expect(response).to redirect_to(stores_path)
        end

        it "フラッシュメッセージが設定される" do
          post stores_path, params: valid_params
          expect(flash[:success]).to eq("店舗を登録しました")
        end
      end

      context "パラメータが無効な場合" do
        let(:invalid_params) { { store: { name: "" } } }

        it "店舗が作成されない" do
          expect { post stores_path, params: invalid_params }.not_to change(Store, :count)
        end

        it "HTTPステータス422を返す" do
          post stores_path, params: invalid_params
          expect(response).to have_http_status(422)
        end

        it "新規登録フォームが再表示される" do
          post stores_path, params: invalid_params
          expect(response.body).to include("店舗登録")
        end
      end

      context "同名店舗が既に存在する場合" do
        let!(:existing_store) { create(:store, user: user, name: "店舗A") }
        let(:duplicate_params) { { store: { name: "店舗A" } } }

        it "店舗が作成されない" do
          expect { post stores_path, params: duplicate_params }.not_to change(Store, :count)
        end

        it "HTTPステータス422を返す" do
          post stores_path, params: duplicate_params
          expect(response).to have_http_status(422)
        end
      end

      context "他のユーザーが同名の店舗を持っている場合" do
        let(:other_user) { create(:user) }
        let!(:other_store) { create(:store, user: other_user, name: "店舗A") }
        let(:valid_params) { { store: { name: "店舗A" } } }

        it "同名はユーザー内のみで一意なので登録できる" do
          expect { post stores_path, params: valid_params }.to change(Store, :count).by(1)
        end
      end
    end
  end

  describe "GET /stores/:id/edit（編集画面）" do
    let!(:store) { create(:store, user: user, name: "店舗A") }

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get edit_store_path(store)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
        get edit_store_path(store)
      end

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "「店舗編集」のタイトルが表示される" do
        expect(response.body).to include("店舗編集")
      end

      it "既存の店舗名がフォームに含まれる" do
        expect(response.body).to include('value="店舗A"')
      end
    end

    context "他のユーザーの店舗にアクセスした場合" do
      let(:other_user) { create(:user) }
      let!(:other_store) { create(:store, user: other_user) }
      
      before { sign_in user }

      it "HTTPステータス404を返す" do
        get edit_store_path(other_store)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "PATCH /stores/:id（更新処理）" do
    let!(:store) { create(:store, user: user, name: "店舗A" ) }

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        patch store_path(store), params: { store: { name: "食品" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "パラメータが有効な場合" do
        let(:valid_params) { { store: { name: "新しい店舗" } } }

        it "店舗名が更新される" do
          patch store_path(store), params: valid_params
          expect(store.reload.name).to eq("新しい店舗")
        end

        it "店舗一覧画面へリダイレクトされる" do
          patch store_path(store), params: valid_params
          expect(response).to redirect_to(stores_path)
        end

        it "フラッシュメッセージが設定される" do
          patch store_path(store), params: valid_params
          expect(flash[:success]).to eq("店舗を更新しました")
        end
      end

      context "パラメータが無効な場合" do
        let(:invalid_params) { { store: { name: ""} } }

        it "更新されない" do
          patch store_path(store), params: invalid_params
          expect(store.reload.name).to eq("店舗A")
        end

        it "HTTPステータス422を返す" do
          patch store_path(store), params: invalid_params
          expect(response).to have_http_status(422)
        end
      end

      context "他のユーザーの店舗を更新しようとした場合" do
        let(:other_user) { create(:user) }
        let!(:other_store) { create(:store, user: other_user, name: "他人の店舗") }

        it "更新されない" do
          patch store_path(other_store), params: { store: { name: "変更" } }
          expect(other_store.reload.name).to eq("他人の店舗")
        end

        it "HTTPステータス404を返す" do
          patch store_path(other_store), params: { store: { name: "変更" } }
          expect(response).to have_http_status(404)
        end
      end
    end
  end

  describe "DELETE /stores/:id（削除処理）" do
    let!(:store) { create(:store, user: user) }

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        delete store_path(store)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "削除されない" do
        expect { delete store_path(store) }.not_to change(Store, :count)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "店舗が1件削除される" do
        expect { delete store_path(store) }.to change(Store, :count).by(-1)
      end

      it "店舗一覧画面へリダイレクトされる" do
        delete store_path(store)
        expect(response).to redirect_to(stores_path)
      end

      it "フラッシュメッセージが設定される" do
        delete store_path(store)
        expect(flash[:success]).to eq("店舗を削除しました")
      end

      context "他のユーザーの店舗を削除しようとした場合" do
        let(:other_user) { create(:user) }
        let!(:other_store) { create(:store, user: other_user) }

        it "削除されない" do
          expect { delete store_path(other_store) }.not_to change(Store, :count)
        end

        it "HTTPステータス404を返す" do
          delete store_path(other_store)
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
