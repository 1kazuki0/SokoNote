require 'rails_helper'

RSpec.describe "Categories", type: :request do
  let(:user) { create(:user) }
  describe "GET /categories（カテゴリー一覧）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get categories_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "カテゴリーが0件の場合" do
        before { get categories_path }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "「カテゴリーがありません」が表示される" do
          expect(response.body).to include("カテゴリーがありません")
        end

        it "カテゴリー新規登録画面へのリンクが含まれる" do
          expect(response.body).to include(new_category_path)
        end
      end

      context "カテゴリーが1件以上ある場合" do
        let!(:category1) { create(:category, user: user, name: "食品") }
        let!(:category2) { create(:category, user: user, name: "日用品") }

        before { get categories_path }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "自分の登録したカテゴリー名が表示される" do
          expect(response.body).to include("食品")
          expect(response.body).to include("日用品")
        end

        it "編集画面へのリンクが含まれる" do
          expect(response.body).to include(edit_category_path(category1))
        end

        it "削除リンクが含まれる" do
          expect(response.body).to include(category_path(category1))
        end

        it "カテゴリー追加ボタンのリンクが含まれる" do
          expect(response.body).to include(new_category_path)
        end
      end

      context "他のユーザーのカテゴリーがある場合" do
        let(:other_user) { create(:user) }
        let!(:other_category) { create(:category, user: other_user, name: "他人のカテゴリー") }

        before { get categories_path }

        it "他のユーザーのカテゴリーは表示されない" do
          expect(response.body).not_to include("他人のカテゴリー")
        end
      end
    end
  end

  describe "GET /categories/new(新規登録画面)" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get new_category_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
        get new_category_path
      end

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "「カテゴリー登録」のタイトルが表示される" do
        expect(response.body).to include("カテゴリー登録")
      end

      it "フォームの送信先パスが含まれる" do
        expect(response.body).to include(categories_path)
      end
    end
  end

  describe "POST /categories（新規登録処理）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        post categories_path, params: { category: { name: "食品" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "パラメータが有効な場合" do
        let(:valid_params) {  { category: { name: "食品" } } }

        it "カテゴリーが1件作成される" do
          expect { post categories_path, params: valid_params }.to change(Category, :count).by(1)
        end

        it "カテゴリー一覧画面へリダイレクトされる" do
          post categories_path, params: valid_params
          expect(response).to redirect_to(categories_path)
        end

        it "フラッシュメッセージが設定される" do
          post categories_path, params: valid_params
          expect(flash[:success]).to eq("カテゴリーを登録しました")
        end
      end

      context "パラメータが無効な場合" do
        let(:invalid_params) { { category: { name: "" } } }

        it "カテゴリーが作成されない" do
          expect { post categories_path, params: invalid_params }.not_to change(Category, :count)
        end

        it "HTTPステータス422を返す" do
          post categories_path, params: invalid_params
          expect(response).to have_http_status(422)
        end

        it "新規登録フォームが再表示される" do
          post categories_path, params: invalid_params
          expect(response.body).to include("カテゴリー登録")
        end
      end

      context "同名カテゴリーが既に存在する場合" do
        let!(:existing_category) { create(:category, user: user, name: "食品") }
        let(:duplicate_params) { { category: { name: "食品" } } }

        it "カテゴリーが作成されない" do
          expect { post categories_path, params: duplicate_params }.not_to change(Category, :count)
        end

        it "HTTPステータス422を返す" do
          post categories_path, params: duplicate_params
          expect(response).to have_http_status(422)
        end
      end

      context "他のユーザーが同名のカテゴリーを持っている場合" do
        let(:other_user) { create(:user) }
        let!(:other_category) { create(:category, user: other_user, name: "食品") }
        let(:valid_params) { { category: { name: "食品" } } }

        it "同名はユーザー内のみで一意なので登録できる" do
          expect { post categories_path, params: valid_params }.to change(Category, :count).by(1)
        end
      end
    end
  end

  describe "GET /categories/:id/edit（編集画面）" do
    let!(:category) { create(:category, user: user, name: "食品") }

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get edit_category_path(category)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
        get edit_category_path(category)
      end

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "「カテゴリー編集」のタイトルが表示される" do
        expect(response.body).to include("カテゴリー編集")
      end

      it "既存のカテゴリー名がフォームに含まれる" do
        expect(response.body).to include('value="食品"')
      end
    end

    context "他のユーザーのカテゴリーにアクセスした場合" do
      let(:other_user) { create(:user) }
      let!(:other_category) { create(:category, user: other_user) }

      before { sign_in user }

      it "HTTPステータス404を返す" do
        get edit_category_path(other_category)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "PATCH /categories/:id（更新処理）" do
    let!(:category) { create(:category, user: user, name: "食品") }

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        patch category_path(category), params: { category: { name: "食品" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "パラメータが有効な場合" do
        let(:valid_params) { { category: { name: "新しいカテゴリー" } } }

        it "カテゴリー名が更新される" do
          patch category_path(category), params: valid_params
          expect(category.reload.name).to eq("新しいカテゴリー")
        end

        it "カテゴリー一覧画面へリダイレクトされる" do
          patch category_path(category), params: valid_params
          expect(response).to redirect_to(categories_path)
        end

        it "フラッシュメッセージが設定される" do
          patch category_path(category), params: valid_params
          expect(flash[:success]).to eq("カテゴリーを更新しました")
        end
      end

      context "パラメータが無効な場合" do
        let(:invalid_params) { { category: { name: "" } } }

        it "更新されない" do
          patch category_path(category), params: invalid_params
          expect(category.reload.name).to eq("食品")
        end

        it "HTTPステータス422を返す" do
          patch category_path(category), params: invalid_params
          expect(response).to have_http_status(422)
        end
      end

      context "他のユーザーのカテゴリーを更新しようとした場合" do
        let(:other_user) { create(:user) }
        let!(:other_category) { create(:category, user: other_user, name: "他人のカテゴリー") }

        it "更新されない" do
          patch category_path(other_category), params: { category: { name: "変更" } }
          expect(other_category.reload.name).to eq("他人のカテゴリー")
        end

        it "HTTPステータス404を返す" do
          patch category_path(other_category), params: { category: { name: "変更" } }
          expect(response).to have_http_status(404)
        end
      end
    end
  end

  describe "DELETE /categories/:id（削除処理）" do
    let!(:category) { create(:category, user: user) }

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        delete category_path(category)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "削除されない" do
        expect { delete category_path(category) }.not_to change(Category, :count)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "カテゴリーが1件削除される" do
        expect { delete category_path(category) }.to change(Category, :count).by(-1)
      end

      it "カテゴリー一覧画面へリダイレクトされる" do
        delete category_path(category)
        expect(response).to redirect_to(categories_path)
      end

      it "フラッシュメッセージが設定される" do
        delete category_path(category)
        expect(flash[:success]).to eq("カテゴリーを削除しました")
      end

      context "他のユーザーのカテゴリーを削除しようとした場合" do
        let(:other_user) { create(:user) }
        let!(:other_category) { create(:category, user: other_user) }

        it "削除されない" do
          expect { delete category_path(other_category) }.not_to change(Category, :count)
        end

        it "HTTPステータス404を返す" do
          delete category_path(other_category)
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
