require "rails_helper"

RSpec.describe "Users::Registrations", type: :request do
  describe "GET /users/sign_up（新規登録画面）" do
    context "ログインしていない場合" do
      before { get new_user_registration_path }
      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "root_path（top画面）へのリンクが含まれる" do
        expect(response.body).to include(root_path)
      end

      it "利用規約へのリンクが含まれる" do
        expect(response.body).to include(terms_path)
      end

      it "プライバシーポリシーへのリンクが含まれる" do
        expect(response.body).to include(privacy_policy_path)
      end

      it "LINE新規登録画面へのリンクが含まれる" do
        expect(response.body).to include(user_line_omniauth_authorize_path)
      end

      it "ログイン画面へのリンクが含まれる" do
        expect(response.body).to include(new_user_session_path)
      end

      it "「新規アカウント登録」文言が含まれる" do
        expect(response.body).to include("新規アカウント登録")
      end
    end

    context "ログインしている場合" do
      let(:user) { create(:user) }
      before do
        sign_in user
        get new_user_registration_path
      end
      it "商品一覧画面にリダイレクトされる" do
        expect(response).to redirect_to(items_path)
      end
    end
  end

  describe "POST /users（新規登録処理）" do
    context "パラメータが有効な場合" do
      let(:user_params) { { user: attributes_for(:user) } }
      it "ユーザーが作成される" do
        expect { post user_registration_path, params: user_params }.to change(User, :count).by(1)
      end

      it "ログイン状態になる" do
        post user_registration_path, params: user_params
        get items_path
        expect(response).to have_http_status(200)
      end

      it "商品一覧画面にリダイレクトされる" do
        post user_registration_path, params: user_params
        expect(response).to redirect_to(items_path)
      end
    end

    context "パラメータが無効な場合" do
      let(:user_params) { { user: attributes_for(:user, email: nil) } }
      it "HTTPステータス422を返す" do
        post user_registration_path, params: user_params
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "GET /users/edit（アカウント編集画面）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get edit_user_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      let(:user) { create(:user) }
      before do
        sign_in user
        get edit_user_registration_path
      end

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "setting_path（設定画面）へのリンクが含まれる" do
        expect(response.body).to include(setting_path)
      end

      it "「プロフィール設定」文言が含まれる" do
        expect(response.body).to include("プロフィール設定")
      end
    end
  end


  describe "PATCH /users（アカウント更新処理）" do
    let(:user) { create(:user) }
    before { sign_in user }

    context "パラメータが有効の場合" do
      let(:user) { create(:user, password: "password") }
      let(:user_params) { { user: { name: "テストネーム" } } }

      it "ユーザー情報が変更される" do
        patch user_registration_path, params: user_params
        expect(user.reload.name).to eq("テストネーム")
      end

      it "設定画面にリダイレクトされる" do
        patch user_registration_path, params: user_params
        expect(response).to redirect_to(setting_path)
      end
    end

    context "パラメータが無効の場合" do
      let(:user_params) { { user: attributes_for(:user, name: nil) } }
      it "HTTPステータス422を返す" do
        patch user_registration_path, params: user_params
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "DELETE /users（アカウント退会処理）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        delete user_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      let!(:user) { create(:user) }
      before { sign_in user }

      it "ユーザーが1件削除される" do
        expect { delete user_registration_path }.to change(User, :count).by(-1)
      end

      it "トップページへリダイレクトされる" do
        delete user_registration_path
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
